#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if python3 -c 'import sys' >/dev/null 2>&1; then
  PYTHON=(python3)
elif python -c 'import sys' >/dev/null 2>&1; then
  PYTHON=(python)
elif py -3 -c 'import sys' >/dev/null 2>&1; then
  PYTHON=(py -3)
else
  printf 'FAIL: Python 3 no está disponible.\n' >&2
  exit 1
fi

"${PYTHON[@]}" - "$ROOT_DIR" <<'PY'
from pathlib import Path
from urllib.parse import unquote, urlsplit
import re
import sys

root = Path(sys.argv[1])
documents = sorted(root.rglob("*.md"))
assert documents, "No se encontraron documentos"

for document in documents:
    text = document.read_text(encoding="utf-8")
    assert text.count("```") % 2 == 0, f"Bloque sin cerrar: {document.relative_to(root)}"
    assert "wget [http" not in text, f"Comando wget con Markdown: {document.relative_to(root)}"
    for destination in re.findall(r"!?\[[^\]]*\]\(([^)\n]+)\)", text):
        parsed = urlsplit(destination)
        if parsed.scheme or destination.startswith("#"):
            continue
        target = document.parent / unquote(parsed.path)
        assert target.exists(), f"Enlace roto en {document.relative_to(root)}: {destination}"

readme = (root / "README.md").read_text(encoding="utf-8")
for expected in ("docs/installation.md", "docs/operations.md", "USAGE.md"):
    assert expected in readme, f"README no enlaza {expected}"

usage = (root / "USAGE.md").read_text(encoding="utf-8")
assert "--check" in usage
assert "--generate" in usage
assert "AngelmzDev/Wazuh-SOC-lab" in usage

print(f"PASS: {len(documents)} documentos y enlaces locales")
PY
