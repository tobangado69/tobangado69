#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${ROOT}/scripts/refresh-trophies.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

mkdir -p "${TMP_DIR}/profile"

TROPHY_USERNAME="tobangado69" \
TROPHY_THEME="tokyonight" \
TROPHY_MARGIN_W="4" \
TROPHY_ENDPOINTS="https://127.0.0.1:9" \
bash "${SCRIPT}" "${TMP_DIR}" >/dev/null 2>&1

grep -q "GitHub Trophies temporarily unavailable" "${TMP_DIR}/profile/trophies.svg"

printf '<svg><text>cached</text></svg>\n' > "${TMP_DIR}/profile/trophies.svg"

TROPHY_USERNAME="tobangado69" \
TROPHY_THEME="tokyonight" \
TROPHY_MARGIN_W="4" \
TROPHY_ENDPOINTS="https://127.0.0.1:9" \
bash "${SCRIPT}" "${TMP_DIR}" >/dev/null 2>&1

grep -q "<text>cached</text>" "${TMP_DIR}/profile/trophies.svg"

echo "trophies refresh fallback checks passed"
