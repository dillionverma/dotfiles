#!/usr/bin/env bash
# Bootstrap a new Mac: Determinate Nix + this flake. Full runbook: docs/bootstrap.md
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/src/personal/dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/dillionverma/dotfiles.git}"
# Which darwinConfigurations host to build; prompted for below if unset.
FLAKE_ATTR="${FLAKE_ATTR:-}"

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

# If Xcode is already installed (e.g. a prior partial run), accept the
# license before the switch — unaccepted licenses abort builds. The
# first-install case (Xcode lands via masApps mid-switch) is handled by
# postActivation in darwin.nix.
if [[ -d /Applications/Xcode.app ]]; then
  if ! DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
      /usr/bin/xcodebuild -license check >/dev/null 2>&1; then
    log "Accepting the Xcode license (requires sudo)."
    sudo DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
      /usr/bin/xcodebuild -license accept
  fi
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

# Pick the flake host (darwinConfigurations attr). Hosts are the mkDarwinHost
# entries in flake.nix; the name flows into the drs alias. Distinct from the
# computer name above, which is set imperatively via scutil.
# Reads from /dev/tty because stdin is the script itself under `curl | bash`.
hosts="$(grep -o 'mkDarwinHost "[^"]*"' "${DOTFILES_DIR}/flake.nix" | cut -d'"' -f2 | tr '\n' ' ')"
hosts="${hosts% }"
[[ -n "$hosts" ]] || fail "no mkDarwinHost entries found in flake.nix."
if [[ -z "$FLAKE_ATTR" ]]; then
  default_attr="$(scutil --get LocalHostName 2>/dev/null || true)"
  case " ${hosts} " in
    *" ${default_attr} "*) ;;
    *) default_attr="${hosts%% *}" ;;
  esac
  if [[ -r /dev/tty ]]; then
    read -r -p "[bootstrap] flake host (one of: ${hosts}) [${default_attr}]: " FLAKE_ATTR </dev/tty || FLAKE_ATTR=""
  fi
  FLAKE_ATTR="${FLAKE_ATTR:-$default_attr}"
fi
case " ${hosts} " in
  *" ${FLAKE_ATTR} "*) ;;
  *) fail "'${FLAKE_ATTR}' is not a host in flake.nix — add: ${FLAKE_ATTR} = mkDarwinHost \"${FLAKE_ATTR}\";" ;;
esac
log "Building host '${FLAKE_ATTR}'."

# nix-darwin refuses to overwrite shell rc files it does not recognize.
for f in /etc/zshrc /etc/bashrc; do
  if [[ -f "$f" && ! -L "$f" ]] && ! grep -q nix-darwin "$f" 2>/dev/null; then
    log "Moving aside $f -> $f.before-nix-darwin."
    sudo mv "$f" "$f.before-nix-darwin"
  fi
done

log "Running the first darwin-rebuild switch."
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake "${DOTFILES_DIR}#${FLAKE_ATTR}"

# The switch installed tools into profiles this shell's PATH predates.
export PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"

if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
  log "Generating ssh key (no passphrase; the keychain guards it)."
  ssh-keygen -t ed25519 -C hello@dillion.io -f "$HOME/.ssh/id_ed25519" -N ""
fi
ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519" 2>/dev/null \
  || log "warning: ssh-add failed; run 'ssh-add --apple-use-keychain ~/.ssh/id_ed25519' manually."

if command -v rustup >/dev/null 2>&1 && ! rustup show active-toolchain >/dev/null 2>&1; then
  log "Setting rustup default toolchain to stable."
  rustup default stable
fi

log "Done. Manual tail (see docs/bootstrap.md): gh auth login, Raycast permissions, app sign-ins, logout/login."
