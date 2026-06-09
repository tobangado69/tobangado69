#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${ROOT}/scripts/sync-profile-assets.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

mkdir -p "${TMP_DIR}/profile"

for asset in \
  activity-graph.svg \
  github-contribution-grid-snake-dark.svg \
  github-contribution-grid-snake.svg \
  pin-InboxIq.svg \
  pin-detect-price-by-photo.svg \
  stats.svg \
  streak.svg \
  top-langs.svg
do
  printf '<svg>%s</svg>\n' "${asset}" > "${TMP_DIR}/profile/${asset}"
done

cat > "${TMP_DIR}/README.md" <<'EOF'
<img src="https://raw.githubusercontent.com/example/repo/main/profile/stats.svg?v=99" />
<img src="https://raw.githubusercontent.com/example/repo/main/profile/top-langs.svg?v=99" />
<img src="https://raw.githubusercontent.com/example/repo/main/profile/streak.svg?v=99" />
<img src="https://raw.githubusercontent.com/example/repo/main/profile/activity-graph.svg?v=99" />
<img src="https://raw.githubusercontent.com/example/repo/main/profile/github-contribution-grid-snake-dark.svg?v=99" />
EOF

PROFILE_REPOSITORY="example/repo" \
PROFILE_CACHE_BUST="4242" \
bash "${SCRIPT}" "${TMP_DIR}"

grep -q 'stats.svg?v=4242' "${TMP_DIR}/README.md"
grep -q 'top-langs.svg?v=4242' "${TMP_DIR}/README.md"
grep -q 'streak.svg?v=4242' "${TMP_DIR}/README.md"
grep -q 'activity-graph.svg?v=4242' "${TMP_DIR}/README.md"
grep -q 'github-contribution-grid-snake-dark.svg?v=4242' "${TMP_DIR}/README.md"

rm "${TMP_DIR}/profile/streak.svg"

if PROFILE_REPOSITORY="example/repo" PROFILE_CACHE_BUST="9001" bash "${SCRIPT}" "${TMP_DIR}" >/dev/null 2>&1; then
  echo "expected sync-profile-assets.sh to fail when a required SVG is missing" >&2
  exit 1
fi

echo "profile automation checks passed"
