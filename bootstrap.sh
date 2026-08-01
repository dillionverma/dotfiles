#!/usr/bin/env bash
# Bootstrap a new Mac: Determinate Nix + this flake. Full runbook: docs/bootstrap.md
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/src/personal/dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/dillionverma/dotfiles.git}"
FLAKE_ATTR="${FLAKE_ATTR:-mbp}"

log() { printf '[bootstrap] %s\n' "$*"; }
fail() { printf '[bootstrap] error: %s\n' "$*" >&2; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || fail "macOS only."

if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools; re-run bootstrap once the install finishes."
  xcode-select --install
  exit 1
fi

if ! command -v nix >/dev/null 2>&1; then
  log "Installing Determinate Nix."
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

if [[ ! -d "${DOTFILES_DIR}/.git" ]]; then
  log "Cloning dotfiles to ${DOTFILES_DIR}."
  mkdir -p "$(dirname "${DOTFILES_DIR}")"
  git clone "${DOTFILES_REPO}" "${DOTFILES_DIR}"
fi

# nix-darwin refuses to overwrite shell rc files it does not recognize.
for f in /etc/zshrc /etc/bashrc; do
  if [[ -f "$f" && ! -L "$f" ]] && ! grep -q nix-darwin "$f" 2>/dev/null; then
    log "Moving aside $f -> $f.before-nix-darwin (requires sudo)."
    sudo mv "$f" "$f.before-nix-darwin"
  fi
done

log "Running the first darwin-rebuild switch (sudo)."
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake "${DOTFILES_DIR}#${FLAKE_ATTR}"

log "Done. Manual tail (see docs/bootstrap.md): ssh key, gh auth login, rustup default stable, app sign-ins, logout/login."
