#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SERVICE="${SCRIPT_DIR}/chatgpt2api.service"
TARGET_SERVICE="/etc/systemd/system/chatgpt2api.service"

if [[ ! -f "${SOURCE_SERVICE}" ]]; then
  echo "service file not found: ${SOURCE_SERVICE}" >&2
  exit 1
fi

if [[ "${EUID}" -ne 0 ]]; then
  if ! command -v sudo >/dev/null 2>&1; then
    echo "run this script as root or install sudo" >&2
    exit 1
  fi

  exec sudo -E bash "${BASH_SOURCE[0]}" "$@"
fi

systemctl stop chatgpt2api >/dev/null 2>&1 || true

install -m 644 "${SOURCE_SERVICE}" "${TARGET_SERVICE}"

systemctl daemon-reload
systemctl enable --now chatgpt2api
systemctl status chatgpt2api --no-pager
