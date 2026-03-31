#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
if command -v git >/dev/null 2>&1 && git -C "${SCRIPT_DIR}" rev-parse --show-toplevel >/dev/null 2>&1; then
  DOTFILES_DIR="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
else
  DOTFILES_DIR="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
fi
MANIFEST="${DOTFILES_DIR}/manifests/vim-plugins.txt"
PACK_ROOT="${HOME}/.vim/pack/vendor/start"

mkdir -p "${PACK_ROOT}"

while IFS= read -r repo; do
  [[ -n "${repo}" ]] || continue
  [[ "${repo}" =~ ^# ]] && continue

  name="$(basename "${repo}" .git)"
  target="${PACK_ROOT}/${name}"

  if [[ -d "${target}/.git" ]]; then
    git -C "${target}" pull --ff-only
  else
    git clone --depth 1 "${repo}" "${target}"
  fi
done < "${MANIFEST}"
