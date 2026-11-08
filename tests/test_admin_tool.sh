#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/wazuh_reset_password.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1" needle="$2"
  [[ "$haystack" == *"$needle"* ]] || fail "No se encontró: $needle"
}

run_tool() {
  set +e
  OUTPUT="$("$@" 2>&1)"
  STATUS=$?
  set -e
}

run_tool bash "$SCRIPT" --help
[[ $STATUS -eq 0 ]] || fail "--help debe terminar correctamente"
assert_contains "$OUTPUT" "--check"
assert_contains "$OUTPUT" "--generate"
assert_contains "$OUTPUT" "--restart"

run_tool env WAZUH_TEST_MODE=1 bash "$SCRIPT"
[[ $STATUS -ne 0 ]] || fail "Sin acción explícita debe fallar"
assert_contains "$OUTPUT" "Elige una acción"

run_tool env WAZUH_TEST_MODE=1 WAZUH_PASSWORD_TOOL="$TMP_DIR/no-existe" bash "$SCRIPT" --generate
[[ $STATUS -ne 0 ]] || fail "Debe fallar si falta la herramienta oficial"
assert_contains "$OUTPUT" "wazuh-passwords-tool.sh"

cat >"$TMP_DIR/wazuh-passwords-tool.sh" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$WAZUH_TEST_LOG"
printf 'INFO: The password for user admin is Generated.Test-42\n'
MOCK
chmod +x "$TMP_DIR/wazuh-passwords-tool.sh"

cat >"$TMP_DIR/systemctl" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$WAZUH_SYSTEMCTL_LOG"
case "$1" in
  is-active) printf 'active\n' ;;
  *) ;;
esac
MOCK
chmod +x "$TMP_DIR/systemctl"

: >"$TMP_DIR/tool.log"
: >"$TMP_DIR/systemctl.log"
run_tool env \
  WAZUH_TEST_MODE=1 \
  WAZUH_PASSWORD_TOOL="$TMP_DIR/wazuh-passwords-tool.sh" \
  WAZUH_SYSTEMCTL="$TMP_DIR/systemctl" \
  WAZUH_TEST_LOG="$TMP_DIR/tool.log" \
  WAZUH_SYSTEMCTL_LOG="$TMP_DIR/systemctl.log" \
  bash "$SCRIPT" --generate
[[ $STATUS -eq 0 ]] || fail "--generate debe usar la herramienta oficial"
[[ "$(cat "$TMP_DIR/tool.log")" == "-u admin" ]] || fail "Argumentos inesperados a la herramienta oficial"
[[ ! -s "$TMP_DIR/systemctl.log" ]] || fail "No debe reiniciar servicios sin --restart"
assert_contains "$OUTPUT" "Generated.Test-42"

: >"$TMP_DIR/tool.log"
: >"$TMP_DIR/systemctl.log"
run_tool env \
  WAZUH_TEST_MODE=1 \
  WAZUH_PASSWORD_TOOL="$TMP_DIR/wazuh-passwords-tool.sh" \
  WAZUH_SYSTEMCTL="$TMP_DIR/systemctl" \
  WAZUH_TEST_LOG="$TMP_DIR/tool.log" \
  WAZUH_SYSTEMCTL_LOG="$TMP_DIR/systemctl.log" \
  bash "$SCRIPT" --generate --restart
[[ $STATUS -eq 0 ]] || fail "--generate --restart debe terminar correctamente"
for service in filebeat wazuh-manager wazuh-dashboard; do
  grep -Fxq "restart $service" "$TMP_DIR/systemctl.log" || fail "Falta reiniciar $service"
  grep -Fxq "is-active $service" "$TMP_DIR/systemctl.log" || fail "Falta verificar $service"
done

: >"$TMP_DIR/tool.log"
: >"$TMP_DIR/systemctl.log"
run_tool env \
  WAZUH_TEST_MODE=1 \
  WAZUH_PASSWORD_TOOL="$TMP_DIR/wazuh-passwords-tool.sh" \
  WAZUH_SYSTEMCTL="$TMP_DIR/systemctl" \
  WAZUH_TEST_LOG="$TMP_DIR/tool.log" \
  WAZUH_SYSTEMCTL_LOG="$TMP_DIR/systemctl.log" \
  bash "$SCRIPT" --check
[[ $STATUS -eq 0 ]] || fail "--check debe terminar correctamente"
[[ ! -s "$TMP_DIR/tool.log" ]] || fail "--check no debe cambiar contraseñas"
for service in wazuh-indexer filebeat wazuh-manager wazuh-dashboard; do
  grep -Fxq "is-active $service" "$TMP_DIR/systemctl.log" || fail "Falta diagnosticar $service"
done

printf 'PASS: utilidad administrativa\n'
