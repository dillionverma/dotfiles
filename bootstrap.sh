#!/usr/bin/env bash
# Bootstrap a new Mac: Determinate Nix + this flake. Full runbook: docs/bootstrap.md
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/src/personal/dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/dillionverma/dotfiles.git}"
FLAKE_ATTR="${FLAKE_ATTR:-mbp}"

log() { printf '[bootstrap] %s\n' "$*"; }
fail() { printf '[bootstrap] error: %s\n' "$*" >&2; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || fail "macOS only."

# Ask everything interactive up front, then run unattended. stdin is a pipe
# under `curl | bash`, so read from the terminal directly.
if [[ -z "${COMPUTER_NAME:-}" && -r /dev/tty ]]; then
  read -rp "Computer name [$(scutil --get ComputerName 2>/dev/null || echo mbp)]: " COMPUTER_NAME </dev/tty || true
fi
COMPUTER_NAME="${COMPUTER_NAME:-$(scutil --get ComputerName 2>/dev/null || echo mbp)}"
# LocalHostName (Bonjour) only allows letters, digits, and hyphens.
LOCAL_HOST_NAME="$(printf '%s' "$COMPUTER_NAME" | tr ' _' '--' | tr -cd 'a-zA-Z0-9-')"

# One password prompt for the whole run: prime sudo, keep the timestamp fresh
# in the background until the script exits.
log "Priming sudo (single password prompt)."
sudo -v
( while kill -0 "$$" 2>/dev/null; do sudo -n true 2>/dev/null; sleep 50; done ) &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools (headless)."
  # Make softwareupdate list the CLT package, then install it non-interactively.
  clt_flag=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  sudo touch "$clt_flag"
  clt_label="$(softwareupdate -l 2>/dev/null \
    | grep -o 'Label: Command Line Tools for Xcode-.*' \
    | sed 's/^Label: //' | sort -V | tail -n1)"
  if [[ -n "$clt_label" ]]; then
    sudo softwareupdate -i "$clt_label" --verbose
  else
    log "Headless install unavailable; launching the GUI installer and waiting."
    xcode-select --install >/dev/null 2>&1 || true
  fi
  sudo rm -f "$clt_flag"
  until xcode-select -p >/dev/null 2>&1; do sleep 10; done
  log "Command Line Tools installed."
fi

log "Setting computer name to '${COMPUTER_NAME}' (LocalHostName '${LOCAL_HOST_NAME}')."
sudo scutil --set ComputerName "$COMPUTER_NAME"
sudo scutil --set HostName "$LOCAL_HOST_NAME"
sudo scutil --set LocalHostName "$LOCAL_HOST_NAME"

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
    log "Moving aside $f -> $f.before-nix-darwin."
    sudo mv "$f" "$f.before-nix-darwin"
  fi
done

log "Running the first darwin-rebuild switch."
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake "${DOTFILES_DIR}#${FLAKE_ATTR}"

log "Done. Manual tail (see docs/bootstrap.md): ssh key, gh auth login, rustup default stable, app sign-ins, logout/login."
