#!/usr/bin/env bash
set -Eeuo pipefail

readonly DEFAULT_PASSWORD_TOOL="/usr/share/wazuh-indexer/plugins/opensearch-security/tools/wazuh-passwords-tool.sh"
readonly SERVICES=(wazuh-indexer filebeat wazuh-manager wazuh-dashboard)

ACTION=""
TARGET_USER="admin"
RESTART_SERVICES=false
PASSWORD_TOOL="${WAZUH_PASSWORD_TOOL:-$DEFAULT_PASSWORD_TOOL}"
SYSTEMCTL="${WAZUH_SYSTEMCTL:-systemctl}"

usage() {
  cat <<'EOF'
Uso:
  sudo ./wazuh_reset_password.sh --check
  sudo ./wazuh_reset_password.sh --generate [--user USUARIO] [--restart]

Acciones:
  --check       Comprueba la herramienta oficial y el estado de los servicios.
  --generate    Genera y aplica una contraseña aleatoria mediante Wazuh.

Opciones:
  --user NAME   Usuario interno del indexer (por defecto: admin).
  --restart     Reinicia y verifica Filebeat, Manager y Dashboard después.
  -h, --help    Muestra esta ayuda.

Esta utilidad está destinada a instalaciones Wazuh All-in-One por paquetes.
No edita internal_users.yml ni ejecuta securityadmin.sh directamente.
EOF
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

parse_args() {
  while (($#)); do
    case "$1" in
      --check|--generate)
        [[ -z "$ACTION" ]] || die "Elige una sola acción."
        ACTION="$1"
        ;;
      --user)
        shift
        (($#)) || die "Falta el valor de --user."
        TARGET_USER="$1"
        ;;
      --restart)
        RESTART_SERVICES=true
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Opción desconocida: $1. Usa --help."
        ;;
    esac
    shift
  done

  [[ -n "$ACTION" ]] || die "Elige una acción: --check o --generate."
  [[ "$TARGET_USER" =~ ^[A-Za-z0-9._-]+$ ]] ||
    die "El nombre de usuario contiene caracteres no permitidos."
  if [[ "$ACTION" == "--check" && "$RESTART_SERVICES" == true ]]; then
    die "--restart solo se puede usar con --generate."
  fi
}

require_root() {
  if [[ "${WAZUH_TEST_MODE:-0}" != "1" && "$EUID" -ne 0 ]]; then
    die "Ejecuta esta utilidad con sudo."
  fi
}

require_password_tool() {
  [[ -f "$PASSWORD_TOOL" ]] ||
    die "No se encontró wazuh-passwords-tool.sh en $PASSWORD_TOOL. Comprueba que este nodo aloja Wazuh Indexer."
}

service_status() {
  local service="$1"
  "$SYSTEMCTL" is-active "$service"
}

check_environment() {
  local failed=0
  require_password_tool
  printf 'Herramienta oficial: %s\n' "$PASSWORD_TOOL"
  printf 'Servicios All-in-One:\n'
  for service in "${SERVICES[@]}"; do
    if service_status "$service"; then
      printf '  [OK] %s\n' "$service"
    else
      printf '  [FALLO] %s\n' "$service"
      failed=1
    fi
  done
  return "$failed"
}

generate_password() {
  require_password_tool
  printf 'Cambiando la contraseña de %s con la herramienta oficial de Wazuh...\n' "$TARGET_USER"
  bash "$PASSWORD_TOOL" -u "$TARGET_USER"
  printf '\nGuarda la contraseña mostrada en un gestor de secretos antes de cerrar esta terminal.\n'
}

restart_and_verify() {
  local service
  for service in filebeat wazuh-manager wazuh-dashboard; do
    printf 'Reiniciando %s...\n' "$service"
    "$SYSTEMCTL" restart "$service"
  done
  for service in filebeat wazuh-manager wazuh-dashboard; do
    service_status "$service" ||
      die "El servicio $service no está activo después del reinicio."
  done
  printf 'Servicios reiniciados y activos.\n'
}

main() {
  parse_args "$@"
  require_root

  case "$ACTION" in
    --check)
      check_environment
      ;;
    --generate)
      generate_password
      if [[ "$RESTART_SERVICES" == true ]]; then
        restart_and_verify
      else
        printf 'No se reiniciaron servicios. Usa --restart si tu mantenimiento lo requiere.\n'
      fi
      ;;
  esac
}

main "$@"
