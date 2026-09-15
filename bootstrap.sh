#!/bin/sh
# Bootstrap a new Mac: Xcode CLT + Determinate Nix + this flake, in one pass.
#
#   sh -c "$(curl -fsSL https://dillion.io/setup)"
#
# POSIX sh on purpose: works under `sh -c`, `curl | sh`, bash, and zsh.
# Idempotent: re-running skips everything already done.
#
# Env overrides (all optional; prompted for when interactive):
#   COMPUTER_NAME   name shown in Finder/Sharing (default: current name)
#   FLAKE_HOST      darwinConfigurations attr to build (default: LocalHostName)
#   DOTFILES_REPO   owner/repo or URL (default: dillionverma/dotfiles)
#   DOTFILES_DIR    checkout path (default: ~/src/personal/dotfiles)
#   NONINTERACTIVE  set to 1 to take every default without asking
#
# Full runbook: docs/bootstrap.md

set -eu
# shellcheck disable=SC3040 # pipefail is not POSIX; macOS /bin/sh (bash, zsh) has it.
(set -o pipefail 2>/dev/null) && set -o pipefail

main() {
  DOTFILES_DIR="${DOTFILES_DIR:-$HOME/src/personal/dotfiles}"
  DOTFILES_REPO="${DOTFILES_REPO:-dillionverma/dotfiles}"
  FLAKE_HOST="${FLAKE_HOST:-}"
  COMPUTER_NAME="${COMPUTER_NAME:-}"
  STEPS=8
  START=$(date +%s)
  USER="${USER:-$(id -un)}"

  setup_colors
  preflight

  ## Interactive part: ask everything up front, then run unattended. ---------
  current_name=$(scutil --get ComputerName 2>/dev/null || echo mbp)
  ask COMPUTER_NAME "Computer name" "$current_name"
  # LocalHostName (Bonjour) allows only letters, digits, and hyphens.
  LOCAL_HOST_NAME=$(printf '%s' "$COMPUTER_NAME" | tr ' _' '--' | tr -cd 'a-zA-Z0-9-')
  [ -n "$LOCAL_HOST_NAME" ] || fail "computer name must contain a letter or digit"
  ask FLAKE_HOST "Flake host (darwinConfigurations attr; added to flake.nix if new)" \
    "$(printf '%s' "$LOCAL_HOST_NAME" | tr '[:upper:]' '[:lower:]')"
  case "$FLAKE_HOST" in
    *[!a-zA-Z0-9_-]*|"") fail "flake host may only contain letters, digits, - and _" ;;
  esac

  step "Priming sudo (one password prompt for the whole run)"
  sudo -v
  ( while kill -0 "$$" 2>/dev/null; do sudo -n true 2>/dev/null; sleep 50; done ) &
  SUDO_KEEPALIVE_PID=$!
  trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

  step "Xcode Command Line Tools"
  install_clt

  step "Computer name"
  set_computer_name

  step "Determinate Nix"
  install_nix

  step "Dotfiles checkout"
  clone_dotfiles
  ensure_host_in_flake
  ensure_identity

  step "darwin-rebuild switch (first run installs Homebrew, apps, fonts, defaults)"
  first_switch

  step "SSH key"
  ensure_ssh_key

  step "Toolchains"
  ensure_rustup

  finish
}

## Output helpers ------------------------------------------------------------

setup_colors() {
  if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    bold=$(printf '\033[1m') dim=$(printf '\033[2m') green=$(printf '\033[32m')
    yellow=$(printf '\033[33m') red=$(printf '\033[31m') reset=$(printf '\033[0m')
  else
    bold='' dim='' green='' yellow='' red='' reset=''
  fi
  step_n=0
}

step() {
  step_n=$((step_n + 1))
  printf '\n%s[%d/%d] %s%s\n' "$bold" "$step_n" "$STEPS" "$1" "$reset"
}
log()  { printf '      %s\n' "$*"; }
skip() { printf '      %s%s%s\n' "$dim" "$*" "$reset"; }
warn() { printf '      %swarning:%s %s\n' "$yellow" "$reset" "$*" >&2; }
fail() { printf '\n%serror:%s %s\n' "$red" "$reset" "$*" >&2; exit 1; }

# ask VAR "prompt" "default": read from the terminal, even under `curl | sh`
# where stdin is the script itself. Honors NONINTERACTIVE and env presets.
ask() {
  _var=$1 _prompt=$2 _default=$3
  eval "_preset=\${$_var:-}"
  if [ -n "$_preset" ]; then
    log "$_prompt: $_preset"
    return
  fi
  _ans=""
  if [ -z "${NONINTERACTIVE:-}" ]; then
    if [ -t 0 ]; then
      printf '%s%s%s [%s]: ' "$bold" "$_prompt" "$reset" "$_default" >&2
      read -r _ans || _ans=""
    elif has_tty; then
      printf '%s%s%s [%s]: ' "$bold" "$_prompt" "$reset" "$_default" >/dev/tty
      read -r _ans </dev/tty || _ans=""
    fi
  fi
  [ -n "$_ans" ] || _ans=$_default
  eval "$_var=\$_ans"
}

# confirm "question": yes/no, defaults to yes. Non-interactive => no.
confirm() {
  _yn=""
  ask _yn "$1 [Y/n]" "y"
  case "$_yn" in y|Y|yes|YES|Yes) return 0 ;; *) return 1 ;; esac
}

# /dev/tty exists even with no controlling terminal (CI, ssh -T); test by opening it.
has_tty() { { : </dev/tty; } 2>/dev/null; }

# Some commands (gh auth login) need a real terminal on stdin.
with_tty() {
  if [ -t 0 ] || ! has_tty; then "$@"; else "$@" </dev/tty; fi
}

## Steps -------------------------------------------------------------------

preflight() {
  [ "$(uname -s)" = Darwin ] || fail "macOS only."
  [ "$(uname -m)" = arm64 ] || fail "Apple Silicon only (the flake pins aarch64-darwin)."
  if ! defaults read MobileMeAccounts Accounts >/dev/null 2>&1; then
    warn "Not signed into iCloud. App Store apps (masApps) need the App Store signed in;"
    warn "sign in now in System Settings, or they will be skipped on this run and installed on the next drs."
  fi
  case "$DOTFILES_REPO" in
    http://*|https://*|git@*|ssh://*) ;;
    github.com/*) DOTFILES_REPO="https://$DOTFILES_REPO" ;;
    */*) DOTFILES_REPO="https://github.com/$DOTFILES_REPO" ;;
    *) fail "DOTFILES_REPO must be owner/repo or a git URL (got '$DOTFILES_REPO')" ;;
  esac
  printf '%sdotfiles bootstrap%s  %s%s -> %s%s\n' "$bold" "$reset" "$dim" "$DOTFILES_REPO" "$DOTFILES_DIR" "$reset"
}

install_clt() {
  if xcode-select -p >/dev/null 2>&1; then
    skip "already installed"
    return
  fi
  log "installing headlessly via softwareupdate"
  # Make softwareupdate list the CLT package, then install it non-interactively.
  clt_flag=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  sudo touch "$clt_flag"
  clt_label=$(softwareupdate -l 2>/dev/null \
    | grep -o 'Label: Command Line Tools for Xcode-.*' \
    | sed 's/^Label: //' | sort -V | tail -n1)
  if [ -n "$clt_label" ]; then
    sudo softwareupdate -i "$clt_label" --verbose
  else
    log "headless install unavailable; launching the GUI installer and waiting"
    xcode-select --install >/dev/null 2>&1 || true
  fi
  sudo rm -f "$clt_flag"
  until xcode-select -p >/dev/null 2>&1; do sleep 10; done
  log "installed"
}

set_computer_name() {
  if [ "$(scutil --get ComputerName 2>/dev/null)" = "$COMPUTER_NAME" ] \
    && [ "$(scutil --get LocalHostName 2>/dev/null)" = "$LOCAL_HOST_NAME" ]; then
    skip "already '$COMPUTER_NAME' ($LOCAL_HOST_NAME)"
    return
  fi
  sudo scutil --set ComputerName "$COMPUTER_NAME"
  sudo scutil --set HostName "$LOCAL_HOST_NAME"
  sudo scutil --set LocalHostName "$LOCAL_HOST_NAME"
  log "set to '$COMPUTER_NAME' (LocalHostName '$LOCAL_HOST_NAME')"
}

install_nix() {
  if command -v nix >/dev/null 2>&1; then
    skip "already installed ($(nix --version))"
  else
    curl -fsSL https://install.determinate.systems/nix \
      | sh -s -- install --determinate --no-confirm
  fi
  # shellcheck disable=SC1091
  [ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] \
    && . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
}

clone_dotfiles() {
  if [ -d "$DOTFILES_DIR/.git" ]; then
    skip "already at $DOTFILES_DIR"
    return
  fi
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone --quiet "$DOTFILES_REPO" "$DOTFILES_DIR"
  log "cloned to $DOTFILES_DIR"
}

# me.nix accessors (plain sed; nix may not be on PATH yet in this shell).
me_get() { sed -n "s/^  $1 = \"\(.*\)\";/\1/p" "$DOTFILES_DIR/me.nix"; }
me_set() { sed -i '' "s|^  $1 = \".*\";|  $1 = \"$2\";|" "$DOTFILES_DIR/me.nix"; }

# git commit that works before user.name/email are configured on this machine.
repo_commit() {
  git -C "$DOTFILES_DIR" \
    -c "user.name=$(me_get fullName)" -c "user.email=$(me_get email)" \
    commit --quiet -m "$1"
}

ensure_host_in_flake() {
  flake="$DOTFILES_DIR/flake.nix"
  hosts=$(grep -o 'mkDarwinHost "[^"]*"' "$flake" | cut -d'"' -f2 | tr '\n' ' ')
  if grep -q "mkDarwinHost \"$FLAKE_HOST\"" "$flake"; then
    skip "host '$FLAKE_HOST' (available: ${hosts% })"
    return
  fi
  # Insert right after the `darwinConfigurations = {` line.
  perl -0pi -e 's/(darwinConfigurations = \{\n)/$1        "'"$FLAKE_HOST"'" = mkDarwinHost "'"$FLAKE_HOST"'";\n/' "$flake"
  grep -q "mkDarwinHost \"$FLAKE_HOST\"" "$flake" \
    || fail "could not add host '$FLAKE_HOST' to flake.nix; add it by hand next to the other mkDarwinHost lines."
  git -C "$DOTFILES_DIR" add flake.nix
  repo_commit "feat(hosts): add $FLAKE_HOST"
  log "added host '$FLAKE_HOST' to flake.nix (committed locally; push when ready)"
}

# me.nix holds username/name/email. If this machine's user is someone else
# (a fork, or a different macOS username), ask and rewrite it.
ensure_identity() {
  me_user=$(me_get username)
  if [ "$me_user" = "$USER" ]; then
    skip "identity: $(me_get fullName) <$(me_get email)> as $me_user"
    return
  fi
  log "me.nix is for '$me_user' but you are '$USER' — personalizing"
  FULL_NAME="${FULL_NAME:-}" EMAIL="${EMAIL:-}" GITHUB_USER="${GITHUB_USER:-}"
  ask FULL_NAME "Full name (git user.name)" "$(id -F 2>/dev/null || echo "$USER")"
  ask EMAIL "Email (git user.email, ssh key comment)" "$USER@$(hostname -s).local"
  ask GITHUB_USER "GitHub username" "$USER"
  me_set username "$USER"
  me_set fullName "$FULL_NAME"
  me_set email "$EMAIL"
  me_set github "$GITHUB_USER"
  git -C "$DOTFILES_DIR" add me.nix
  repo_commit "chore(me): personalize for $USER"
  log "me.nix updated and committed locally"
}

first_switch() {
  # If Xcode is already present (a prior partial run), accept its license before
  # the switch — unaccepted licenses abort builds. First-install is handled by
  # postActivation in darwin.nix.
  if [ -d /Applications/Xcode.app ] \
    && ! DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
      /usr/bin/xcodebuild -license check >/dev/null 2>&1; then
    log "accepting the Xcode license"
    sudo DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
      /usr/bin/xcodebuild -license accept
  fi

  # nix-darwin refuses to overwrite shell rc files it does not recognize.
  for f in /etc/zshrc /etc/bashrc; do
    if [ -f "$f" ] && [ ! -L "$f" ] && ! grep -q nix-darwin "$f" 2>/dev/null; then
      log "moving aside $f -> $f.before-nix-darwin"
      sudo mv "$f" "$f.before-nix-darwin"
    fi
  done

  if command -v darwin-rebuild >/dev/null 2>&1; then
    log "darwin-rebuild switch --flake $DOTFILES_DIR#$FLAKE_HOST"
    sudo darwin-rebuild switch --flake "$DOTFILES_DIR#$FLAKE_HOST"
  else
    log "nix run nix-darwin#darwin-rebuild -- switch --flake $DOTFILES_DIR#$FLAKE_HOST"
    sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake "$DOTFILES_DIR#$FLAKE_HOST"
  fi

  # The switch installed tools into profiles this shell's PATH predates.
  PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"
  export PATH
}

ensure_ssh_key() {
  key="$HOME/.ssh/id_ed25519"
  if [ -f "$key" ]; then
    skip "$key exists"
  else
    ssh-keygen -q -t ed25519 -C "$(me_get email)" -f "$key" -N ""
    log "generated $key (no passphrase; the keychain guards it)"
  fi
  ssh-add --apple-use-keychain "$key" 2>/dev/null \
    || warn "ssh-add failed; run: ssh-add --apple-use-keychain $key"
}

ensure_rustup() {
  if ! command -v rustup >/dev/null 2>&1; then
    skip "rustup not on PATH; skipping"
  elif rustup show active-toolchain >/dev/null 2>&1; then
    skip "rustup: $(rustup show active-toolchain 2>/dev/null | cut -d' ' -f1)"
  else
    rustup default stable
    log "rustup default toolchain set to stable"
  fi
}

## Wrap-up -----------------------------------------------------------------

finish() {
  elapsed=$(( $(date +%s) - START ))
  printf '\n%s%sDone%s in %dm %02ds. What is left needs a human:\n\n' "$bold" "$green" "$reset" $((elapsed / 60)) $((elapsed % 60))

  # 1. GitHub: gh auth + register the ssh key (git over ssh needs it).
  if command -v gh >/dev/null 2>&1; then
    if gh auth status >/dev/null 2>&1; then
      printf '  %s✓%s GitHub: gh is authenticated\n' "$green" "$reset"
    elif confirm "  1. GitHub: run 'gh auth login' now?"; then
      with_tty gh auth login || warn "gh auth login failed; run it later"
    else
      printf '  %s·%s later: gh auth login\n' "$dim" "$reset"
    fi
    pub="$HOME/.ssh/id_ed25519.pub"
    if gh auth status >/dev/null 2>&1 && [ -f "$pub" ]; then
      if gh ssh-key list 2>/dev/null | grep -qF "$(cut -d' ' -f2 "$pub")"; then
        printf '  %s✓%s GitHub: ssh key already registered\n' "$green" "$reset"
      else
        if gh ssh-key add "$pub" --title "$COMPUTER_NAME"; then
          printf '  %s✓%s GitHub: ssh key registered as "%s"\n' "$green" "$reset" "$COMPUTER_NAME"
        else
          warn "could not add ssh key; run: gh ssh-key add $pub --title \"$COMPUTER_NAME\""
        fi
      fi
    fi
  else
    printf '  %s·%s later: gh auth login && gh ssh-key add ~/.ssh/id_ed25519.pub --title "%s"\n' "$dim" "$reset" "$COMPUTER_NAME"
  fi

  # 2. Raycast owns cmd+space, but TCC grants cannot be automated without MDM.
  if [ -d /Applications/Raycast.app ]; then
    if confirm "  2. Raycast: open the Accessibility / Calendars / Full Disk Access panes now?"; then
      open -g -a Raycast 2>/dev/null || true
      for pane in Privacy_Accessibility Privacy_Calendars Privacy_AllFiles; do
        open "x-apple.systempreferences:com.apple.preference.security?$pane"
      done
      printf '     grant Raycast in each pane, then quit and relaunch Raycast\n'
    else
      printf '  %s·%s later: grant Raycast Accessibility, Calendars, Full Disk Access in System Settings > Privacy\n' "$dim" "$reset"
    fi
  fi

  cat <<EOM
  3. Sign into apps: Tailscale, Bitwarden, Slack, 1Password, ... and run: infisical login
  4. App Store apps only install while signed into the App Store (re-run 'drs' after signing in).
  5. Log out and back in: keyboard-repeat defaults and the cmd+space handoff apply at login.

Daily driving: drs (rebuild + switch) · darwin-rebuild --list-generations · sudo darwin-rebuild switch --rollback
Config lives in $DOTFILES_DIR
EOM
}

main "$@"
