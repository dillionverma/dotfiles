#!/usr/bin/env bash

set -euo pipefail

INSTALL_BASE_URL="${INSTALL_BASE_URL:-https://dillion.io/install}"
INSTALL_SOURCE_DIR="${INSTALL_SOURCE_DIR:-}"

log() {
  printf '[bootstrap] %s\n' "$*"
}

fail() {
  printf '[bootstrap] %s\n' "$*" >&2
  exit 1
}

require_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    fail "This installer currently supports macOS only."
  fi
}

copy_local_source() {
  local src="$1"
  local dest="$2"

  mkdir -p "${dest}/scripts" "${dest}/manifests"
  cp "${src}/Brewfile.core" "${dest}/Brewfile.core"
  cp "${src}/Brewfile.full" "${dest}/Brewfile.full"
  cp "${src}/README.md" "${dest}/README.md"
  cp "${src}/scripts/setup-macos.sh" "${dest}/scripts/setup-macos.sh"
  cp "${src}/manifests/npm-global-packages.txt" "${dest}/manifests/npm-global-packages.txt"
  cp "${src}/manifests/uv-tools.txt" "${dest}/manifests/uv-tools.txt"
  cp "${src}/manifests/cargo-packages.txt" "${dest}/manifests/cargo-packages.txt"
  cp "${src}/manifests/dock-items.txt" "${dest}/manifests/dock-items.txt"
}

download_remote_source() {
  local dest="$1"

  mkdir -p "${dest}/scripts" "${dest}/manifests"
  curl -fsSL "${INSTALL_BASE_URL%/}/Brewfile.core" -o "${dest}/Brewfile.core"
  curl -fsSL "${INSTALL_BASE_URL%/}/Brewfile.full" -o "${dest}/Brewfile.full"
  curl -fsSL "${INSTALL_BASE_URL%/}/README.md" -o "${dest}/README.md"
  curl -fsSL "${INSTALL_BASE_URL%/}/scripts/setup-macos.sh" -o "${dest}/scripts/setup-macos.sh"
  curl -fsSL "${INSTALL_BASE_URL%/}/manifests/npm-global-packages.txt" -o "${dest}/manifests/npm-global-packages.txt"
  curl -fsSL "${INSTALL_BASE_URL%/}/manifests/uv-tools.txt" -o "${dest}/manifests/uv-tools.txt"
  curl -fsSL "${INSTALL_BASE_URL%/}/manifests/cargo-packages.txt" -o "${dest}/manifests/cargo-packages.txt"
  curl -fsSL "${INSTALL_BASE_URL%/}/manifests/dock-items.txt" -o "${dest}/manifests/dock-items.txt"
}

main() {
  local work_dir
  work_dir="$(mktemp -d "${TMPDIR:-/tmp}/new-laptop-setup.XXXXXX")"
  trap 'rm -rf "${work_dir}"' EXIT

  require_macos

  if [[ -n "${INSTALL_SOURCE_DIR}" && -d "${INSTALL_SOURCE_DIR}" ]]; then
    log "Using local installer source from ${INSTALL_SOURCE_DIR}"
    copy_local_source "${INSTALL_SOURCE_DIR}" "${work_dir}"
  else
    log "Fetching installer assets from ${INSTALL_BASE_URL}"
    download_remote_source "${work_dir}"
  fi

  chmod +x "${work_dir}/scripts/setup-macos.sh"
  exec "${work_dir}/scripts/setup-macos.sh" "$@"
}

main "$@"
