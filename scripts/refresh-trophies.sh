#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="${1:-.}"
TROPHY_PATH="${ROOT_DIR}/profile/trophies.svg"
USERNAME="${TROPHY_USERNAME:-}"
THEME="${TROPHY_THEME:-tokyonight}"
MARGIN_W="${TROPHY_MARGIN_W:-4}"

if [[ -z "${USERNAME}" ]]; then
  echo "TROPHY_USERNAME is required" >&2
  exit 1
fi

mkdir -p "$(dirname "${TROPHY_PATH}")"

tmp_file="$(mktemp)"
trap 'rm -f "${tmp_file}"' EXIT

write_fallback() {
  cat > "${TROPHY_PATH}" <<EOF
<svg xmlns="http://www.w3.org/2000/svg" width="720" height="120" viewBox="0 0 720 120" role="img" aria-labelledby="title desc">
  <title id="title">GitHub profile trophies unavailable</title>
  <desc id="desc">Cached fallback rendered because trophy endpoints were unavailable.</desc>
  <rect width="720" height="120" rx="16" fill="#1a1b27"/>
  <text x="36" y="52" fill="#e5e9f0" font-family="Segoe UI, Arial, sans-serif" font-size="26" font-weight="700">GitHub Trophies temporarily unavailable</text>
  <text x="36" y="84" fill="#8fbcbb" font-family="Segoe UI, Arial, sans-serif" font-size="20">Profile trophies will refresh automatically when the endpoint recovers.</text>
</svg>
EOF
}

url_suffix="/?username=${USERNAME}&theme=${THEME}&no-frame=true&no-bg=true&margin-w=${MARGIN_W}"

if [[ -n "${TROPHY_ENDPOINTS:-}" ]]; then
  read -r -a trophy_endpoints <<< "${TROPHY_ENDPOINTS}"
else
  trophy_endpoints=(
    "https://github-profile-trophy.vercel.app"
    "https://github-profile-trophy-liard-delta.vercel.app"
    "https://trophy.ryglcloud.net"
  )
fi

for base_url in "${trophy_endpoints[@]}"
do
  if curl -fsSL --retry 3 --retry-all-errors --connect-timeout 10 "${base_url}${url_suffix}" -o "${tmp_file}" && grep -q "<svg" "${tmp_file}"; then
    mv "${tmp_file}" "${TROPHY_PATH}"
    exit 0
  fi
done

if [[ -s "${TROPHY_PATH}" ]] && grep -q "<svg" "${TROPHY_PATH}"; then
  echo "Trophy endpoints unavailable; keeping existing cached trophies.svg" >&2
  exit 0
fi

echo "Trophy endpoints unavailable; writing fallback trophies.svg" >&2
write_fallback
