#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

link_file() {
  local source_path="$1"
  local target_path="$2"
  local backup_path=""

  mkdir -p "$(dirname "${target_path}")"

  if [[ -L "${target_path}" ]]; then
    rm "${target_path}"
  elif [[ -e "${target_path}" ]]; then
    backup_path="${target_path}.backup-${TIMESTAMP}"
    mv "${target_path}" "${backup_path}"
    printf '[link-dotfiles] backed up %s to %s\n' "${target_path}" "${backup_path}"
  fi

  ln -s "${source_path}" "${target_path}"
  printf '[link-dotfiles] linked %s -> %s\n' "${target_path}" "${source_path}"
}

link_file "${DOTFILES_DIR}/.zshrc" "${HOME}/.zshrc"
