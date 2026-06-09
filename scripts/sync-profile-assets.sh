#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="${1:-.}"
README_PATH="${ROOT_DIR}/README.md"
PROFILE_DIR="${ROOT_DIR}/profile"

if [[ -z "${PROFILE_REPOSITORY:-}" ]]; then
  echo "PROFILE_REPOSITORY is required" >&2
  exit 1
fi

if [[ -z "${PROFILE_CACHE_BUST:-}" ]]; then
  echo "PROFILE_CACHE_BUST is required" >&2
  exit 1
fi

if [[ ! -f "${README_PATH}" ]]; then
  echo "README not found at ${README_PATH}" >&2
  exit 1
fi

required_assets=(
  activity-graph.svg
  github-contribution-grid-snake-dark.svg
  github-contribution-grid-snake.svg
  pin-InboxIq.svg
  pin-detect-price-by-photo.svg
  stats.svg
  streak.svg
  top-langs.svg
  trophies.svg
)

for asset in "${required_assets[@]}"; do
  asset_path="${PROFILE_DIR}/${asset}"
  if [[ ! -s "${asset_path}" ]]; then
    echo "Required profile asset is missing or empty: ${asset_path}" >&2
    exit 1
  fi
done

export PROFILE_REPOSITORY PROFILE_CACHE_BUST

perl -0pi -e '
  s{
    https://raw\.githubusercontent\.com/[^/\s]+/[^/\s]+/main/profile/([^"?\s]+)
    (?:\?[^"\s>]*)?
  }{
    "https://raw.githubusercontent.com/$ENV{PROFILE_REPOSITORY}/main/profile/$1?v=$ENV{PROFILE_CACHE_BUST}"
  }gex
' "${README_PATH}"
