#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
if command -v git >/dev/null 2>&1 && git -C "${SCRIPT_DIR}" rev-parse --show-toplevel >/dev/null 2>&1; then
  DOTFILES_DIR="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
else
  DOTFILES_DIR="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
fi
DOTFILES_DIR="$(cd "${DOTFILES_DIR}" && pwd -P)"
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
link_file "${DOTFILES_DIR}/.vimrc" "${HOME}/.vimrc"
link_file "${DOTFILES_DIR}/.vim/colors/vesper.vim" "${HOME}/.vim/colors/vesper.vim"
link_file "${DOTFILES_DIR}/.config/ghostty/config" "${HOME}/.config/ghostty/config"
link_file "${DOTFILES_DIR}/.config/mise/config.toml" "${HOME}/.config/mise/config.toml"
link_file "${DOTFILES_DIR}/.config/ohmyposh/vesper.omp.json" "${HOME}/.config/ohmyposh/vesper.omp.json"
link_file "${DOTFILES_DIR}/.superset/themes/vesper.json" "${HOME}/.superset/themes/vesper.json"
