#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

BREWFILE_PATH="${BREWFILE_PATH:-}"
BREWFILE_CORE_PATH="${BREWFILE_CORE_PATH:-${INSTALLER_ROOT}/Brewfile.core}"
BREWFILE_FULL_PATH="${BREWFILE_FULL_PATH:-${INSTALLER_ROOT}/Brewfile.full}"
NPM_PACKAGES_FILE="${NPM_PACKAGES_FILE:-${INSTALLER_ROOT}/manifests/npm-global-packages.txt}"
UV_TOOLS_FILE="${UV_TOOLS_FILE:-${INSTALLER_ROOT}/manifests/uv-tools.txt}"
CARGO_PACKAGES_FILE="${CARGO_PACKAGES_FILE:-${INSTALLER_ROOT}/manifests/cargo-packages.txt}"
DOCK_ITEMS_FILE="${DOCK_ITEMS_FILE:-${INSTALLER_ROOT}/manifests/dock-items.txt}"
MISE_CONFIG_FILE="${MISE_CONFIG_FILE:-${INSTALLER_ROOT}/.config/mise/config.toml}"
SETUP_MODE="${SETUP_MODE:-full}"
COMPUTER_NAME="${COMPUTER_NAME:-mbp}"
GIT_USER_NAME="${GIT_USER_NAME:-Dillion Verma}"
GIT_USER_EMAIL="${GIT_USER_EMAIL:-hello@dillion.io}"

DRY_RUN=0
ONLY_PHASES_CSV=""
SKIP_PHASES_CSV=""
KNOWN_PHASES="preflight system brew auth dev defaults dock"
CURRENT_PHASE=""
RAN_PHASES=""
SKIPPED_PHASES=""
BREWFILE_USED=""
MAS_SKIPPED=0
GH_AUTH_RESULT="not_run"
DOCK_RESULT="not_run"
DOCK_ITEMS_ADDED=0
DOCK_ITEMS_SKIPPED=0

log() {
  printf '[setup] %s\n' "$*"
}

warn() {
  printf '[setup] warning: %s\n' "$*" >&2
}

fail() {
  printf '[setup] error: %s\n' "$*" >&2
  exit 1
}

append_csv_value() {
  local var_name="$1"
  local value="$2"
  local current="${!var_name:-}"

  if [[ -n "${current}" ]]; then
    printf -v "${var_name}" '%s, %s' "${current}" "${value}"
  else
    printf -v "${var_name}" '%s' "${value}"
  fi
}

usage() {
  cat <<'EOF'
Usage: setup-macos.sh [options]

Options:
  --only PHASES   Run only the comma-separated phases.
  --skip PHASES   Skip the comma-separated phases.
  --list-phases   Print the available phases and exit.
  --dry-run       Print the phases that would run.
  --help          Show this help text.

Phases:
  preflight, system, brew, auth, dev, defaults, dock
EOF
}

list_phases() {
  cat <<'EOF'
preflight
system
brew
auth
dev
defaults
dock
EOF
}

csv_lines() {
  local input="${1:-}"

  if [[ -z "${input}" ]]; then
    return 0
  fi

  while [[ "${input}" == *,* ]]; do
    printf '%s\n' "${input%%,*}"
    input="${input#*,}"
  done

  printf '%s\n' "${input}"
}

trim() {
  local value="${1:-}"

  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "${value}"
}

validate_phase_csv() {
  local csv_value="${1:-}"
  local item

  for item in $(csv_lines "${csv_value}"); do
    item="$(trim "${item}")"
    [[ -n "${item}" ]] || continue
    case " ${KNOWN_PHASES} " in
      *" ${item} "*) ;;
      *)
        fail "Unknown phase: ${item}"
        ;;
    esac
  done
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --only)
        shift
        [[ $# -gt 0 ]] || fail "--only requires a comma-separated value"
        ONLY_PHASES_CSV="$1"
        validate_phase_csv "${ONLY_PHASES_CSV}"
        ;;
      --skip)
        shift
        [[ $# -gt 0 ]] || fail "--skip requires a comma-separated value"
        SKIP_PHASES_CSV="$1"
        validate_phase_csv "${SKIP_PHASES_CSV}"
        ;;
      --dry-run)
        DRY_RUN=1
        ;;
      --list-phases)
        list_phases
        exit 0
        ;;
      --help)
        usage
        exit 0
        ;;
      *)
        fail "Unknown argument: $1"
        ;;
    esac
    shift
  done
}

phase_selected() {
  local phase="$1"
  local value

  if [[ -n "${ONLY_PHASES_CSV}" ]]; then
    for value in $(csv_lines "${ONLY_PHASES_CSV}"); do
      value="$(trim "${value}")"
      if [[ "${value}" == "${phase}" ]]; then
        break
      fi
    done
    if [[ "${value:-}" != "${phase}" ]]; then
      return 1
    fi
  fi

  for value in $(csv_lines "${SKIP_PHASES_CSV}"); do
    value="$(trim "${value}")"
    if [[ "${value}" == "${phase}" ]]; then
      return 1
    fi
  done

  return 0
}

run_step() {
  local phase="$1"
  local description="$2"
  shift 2

  if ! phase_selected "${phase}"; then
    append_csv_value SKIPPED_PHASES "${phase}"
    log "Skipping phase: ${phase}"
    return
  fi

  if [[ "${DRY_RUN}" -eq 1 ]]; then
    log "Would run ${phase}: ${description}"
    return
  fi

  CURRENT_PHASE="${phase}"
  append_csv_value RAN_PHASES "${phase}"
  log "Running ${phase}: ${description}"
  "$@"
}

require_macos() {
  [[ "$(uname -s)" == "Darwin" ]] || fail "This installer currently supports macOS only."
}

validate_setup_mode() {
  case "${SETUP_MODE}" in
    core|full) ;;
    *)
      fail "Unknown SETUP_MODE: ${SETUP_MODE}. Expected one of: core, full"
      ;;
  esac
}

has_tty() {
  [[ -r /dev/tty && -w /dev/tty ]]
}

prompt_continue() {
  local prompt="$1"

  has_tty || fail "This step needs an interactive terminal. Re-run from a shell session or skip the phase."
  read -r -p "${prompt}" </dev/tty
}

require_brew() {
  command -v brew >/dev/null 2>&1 || fail "Homebrew is required for this phase."
}

file_exists_or_warn() {
  local path="$1"

  if [[ ! -f "${path}" ]]; then
    warn "Expected file not found: ${path}"
    return 1
  fi
}

selected_brewfile_path() {
  if [[ -n "${BREWFILE_PATH}" ]]; then
    printf '%s\n' "${BREWFILE_PATH}"
    return 0
  fi

  case "${SETUP_MODE}" in
    core)
      printf '%s\n' "${BREWFILE_CORE_PATH}"
      ;;
    full)
      printf '%s\n' "${BREWFILE_FULL_PATH}"
      ;;
  esac
}

resolve_path() {
  local raw_path="$1"

  case "${raw_path}" in
    "~/"*)
      printf '%s\n' "${HOME}/${raw_path#~/}"
      ;;
    '$'{HOME}/*)
      printf '%s\n' "${HOME}/${raw_path#\$\{HOME\}/}"
      ;;
    *)
      printf '%s\n' "${raw_path}"
      ;;
  esac
}

brew_shellenv() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

ensure_xcode_tools() {
  if xcode-select -p >/dev/null 2>&1; then
    log "Xcode Command Line Tools already installed."
    return
  fi

  log "Installing Xcode Command Line Tools."
  xcode-select --install >/dev/null 2>&1 || true
  prompt_continue "Finish the Command Line Tools install, then press Enter to continue..."

  xcode-select -p >/dev/null 2>&1 || fail "Xcode Command Line Tools are still unavailable."
}

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    brew_shellenv
    log "Homebrew already installed."
    return
  fi

  log "Installing Homebrew."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew_shellenv
  command -v brew >/dev/null 2>&1 || fail "Homebrew installation did not complete successfully."
}

configure_computer_name() {
  if [[ -z "${COMPUTER_NAME}" ]]; then
    warn "COMPUTER_NAME is empty; skipping system naming."
    return
  fi

  sudo -v
  sudo scutil --set ComputerName "${COMPUTER_NAME}"
  sudo scutil --set HostName "${COMPUTER_NAME}"
  sudo scutil --set LocalHostName "${COMPUTER_NAME}"
}

ensure_ssh_key() {
  local key_path="${HOME}/.ssh/id_ed25519"

  mkdir -p "${HOME}/.ssh"
  chmod 700 "${HOME}/.ssh"

  if [[ -f "${key_path}" ]]; then
    log "SSH key already exists at ${key_path}."
    return
  fi

  ssh-keygen -t ed25519 -C "${GIT_USER_EMAIL}" -f "${key_path}" -N ""
}

ensure_ssh_config() {
  local config_path="${HOME}/.ssh/config"
  local marker_begin="# >>> new-laptop-setup >>>"
  local marker_end="# <<< new-laptop-setup <<<"

  touch "${config_path}"
  chmod 600 "${config_path}"

  if grep -Fq "${marker_begin}" "${config_path}"; then
    log "SSH config block already present."
    return
  fi

  cat >>"${config_path}" <<EOF
${marker_begin}
Host *
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ed25519
${marker_end}
EOF
}

start_ssh_agent() {
  if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
    eval "$(ssh-agent -s)" >/dev/null
  fi
}

add_ssh_key_to_agent() {
  local key_path="${HOME}/.ssh/id_ed25519"

  if [[ ! -f "${key_path}" ]]; then
    fail "Expected SSH key at ${key_path}"
  fi

  ssh-add --apple-use-keychain "${key_path}" >/dev/null 2>&1 \
    || ssh-add -K "${key_path}" >/dev/null 2>&1 \
    || ssh-add "${key_path}" >/dev/null 2>&1
}

copy_ssh_key_to_clipboard() {
  local pub_key_path="${HOME}/.ssh/id_ed25519.pub"

  if command -v pbcopy >/dev/null 2>&1; then
    pbcopy <"${pub_key_path}"
    log "Copied SSH public key to the clipboard."
  fi
}

configure_git() {
  git config --global user.name "${GIT_USER_NAME}"
  git config --global user.email "${GIT_USER_EMAIL}"
}

ensure_github_auth() {
  if ! command -v gh >/dev/null 2>&1; then
    GH_AUTH_RESULT="skipped (gh not installed)"
    warn "GitHub CLI is not installed; skipping GitHub auth."
    return
  fi

  if gh auth status >/dev/null 2>&1; then
    GH_AUTH_RESULT="already authenticated"
    log "GitHub CLI already authenticated."
    return
  fi

  if ! has_tty; then
    GH_AUTH_RESULT="skipped (no interactive terminal)"
    warn "No interactive terminal available. Skipping GitHub auth."
    return
  fi

  log "Starting GitHub CLI login. You can upload the copied SSH key during auth if needed."
  gh auth login </dev/tty
  GH_AUTH_RESULT="logged in during setup"
}

brew_bundle_install() {
  local bundle_file
  local temp_bundle=""

  require_brew
  bundle_file="$(selected_brewfile_path)"
  [[ -f "${bundle_file}" ]] || fail "Brewfile not found at ${bundle_file}"
  BREWFILE_USED="${bundle_file}"
  MAS_SKIPPED=0

  if ! command -v mas >/dev/null 2>&1 || ! mas account >/dev/null 2>&1; then
    warn "Mac App Store is not signed in. Skipping mas installs for this run."
    MAS_SKIPPED=1
    temp_bundle="$(mktemp "${TMPDIR:-/tmp}/Brewfile.no-mas.XXXXXX")"
    grep -v '^mas ' "${bundle_file}" >"${temp_bundle}"
    bundle_file="${temp_bundle}"
  fi

  brew bundle --file="${bundle_file}" --no-upgrade

  if [[ -n "${temp_bundle}" ]]; then
    rm -f "${temp_bundle}"
  fi
}

install_rust() {
  if command -v rustup >/dev/null 2>&1; then
    log "Rustup already installed."
    return
  fi

  curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y
}

sync_mise_global_config() {
  file_exists_or_warn "${MISE_CONFIG_FILE}" || return 1
  mkdir -p "${HOME}/.config/mise"
  cp "${MISE_CONFIG_FILE}" "${HOME}/.config/mise/config.toml"
}

install_mise_tools() {
  local tool=""
  local version=""
  local tools=()

  command -v mise >/dev/null 2>&1 || {
    warn "mise is unavailable; skipping mise-managed runtimes."
    return
  }

  sync_mise_global_config || return

  while IFS='=' read -r tool version || [[ -n "${tool}${version}" ]]; do
    tool="$(trim "${tool}")"
    version="$(trim "${version}")"

    case "${tool}" in
      ''|\#*|'[tools]'*)
        continue
        ;;
    esac

    version="${version#\"}"
    version="${version%\"}"
    [[ -n "${version}" ]] || continue
    tools+=("${tool}@${version}")
  done <"${MISE_CONFIG_FILE}"

  if [[ "${#tools[@]}" -eq 0 ]]; then
    warn "No mise tools were configured in ${MISE_CONFIG_FILE}."
    return
  fi

  mise install -y "${tools[@]}" >/dev/null
}

run_npm() {
  if command -v npm >/dev/null 2>&1; then
    npm "$@"
    return
  fi

  if command -v mise >/dev/null 2>&1; then
    mise exec -- npm "$@"
    return
  fi

  return 127
}

install_npm_global_packages() {
  local package

  file_exists_or_warn "${NPM_PACKAGES_FILE}" || return
  run_npm --version >/dev/null 2>&1 || {
    warn "npm is unavailable; skipping npm global packages."
    return
  }

  while IFS= read -r package || [[ -n "${package}" ]]; do
    package="$(trim "${package}")"
    case "${package}" in
      ''|\#*)
        continue
        ;;
    esac

    if run_npm list -g --depth=0 "${package}" >/dev/null 2>&1; then
      log "npm package already installed: ${package}"
      continue
    fi

    run_npm install -g "${package}" >/dev/null
  done <"${NPM_PACKAGES_FILE}"
}

install_uv_tools() {
  local package

  file_exists_or_warn "${UV_TOOLS_FILE}" || return
  command -v uv >/dev/null 2>&1 || {
    warn "uv is unavailable; skipping uv tools."
    return
  }

  while IFS= read -r package || [[ -n "${package}" ]]; do
    package="$(trim "${package}")"
    case "${package}" in
      ''|\#*)
        continue
        ;;
    esac

    if uv tool list | grep -Eq "^${package}([[:space:]]|$)"; then
      log "uv tool already installed: ${package}"
      continue
    fi

    uv tool install "${package}" >/dev/null
  done <"${UV_TOOLS_FILE}"
}

install_cargo_packages() {
  local package

  file_exists_or_warn "${CARGO_PACKAGES_FILE}" || return
  command -v cargo >/dev/null 2>&1 || {
    warn "cargo is unavailable; skipping cargo packages."
    return
  }

  while IFS= read -r package || [[ -n "${package}" ]]; do
    package="$(trim "${package}")"
    case "${package}" in
      ''|\#*)
        continue
        ;;
    esac

    if cargo install --list | grep -Eq "^${package} v"; then
      log "cargo package already installed: ${package}"
      continue
    fi

    cargo install --locked "${package}" >/dev/null
  done <"${CARGO_PACKAGES_FILE}"
}

brew_install_if_missing() {
  local formula="$1"

  require_brew
  if brew list "${formula}" >/dev/null 2>&1; then
    return
  fi

  brew install "${formula}"
}

clone_if_missing() {
  local repo_url="$1"
  local dest="$2"

  if [[ -d "${dest}/.git" ]]; then
    log "Repository already present at ${dest}."
    return
  fi

  mkdir -p "$(dirname "${dest}")"
  git clone "${repo_url}" "${dest}"
}

ensure_plugin_managers() {
  clone_if_missing "https://github.com/tarjoilija/zgen.git" "${HOME}/.zgen"
  clone_if_missing "https://github.com/tmux-plugins/tpm" "${HOME}/.tmux/plugins/tpm"
  clone_if_missing "https://github.com/VundleVim/Vundle.vim.git" "${HOME}/.vim/bundle/Vundle.vim"
}

start_brew_services() {
  local service

  require_brew
  for service in redis postgresql; do
    if brew list "${service}" >/dev/null 2>&1; then
      brew services start "${service}" >/dev/null
    fi
  done
}

configure_dock() {
  local item
  local resolved

  file_exists_or_warn "${DOCK_ITEMS_FILE}" || return
  brew_install_if_missing "dockutil"
  DOCK_RESULT="configured"
  DOCK_ITEMS_ADDED=0
  DOCK_ITEMS_SKIPPED=0

  dockutil --remove all --no-restart >/dev/null

  while IFS= read -r item || [[ -n "${item}" ]]; do
    item="$(trim "${item}")"
    case "${item}" in
      ''|\#*)
        continue
        ;;
    esac

    resolved="$(resolve_path "${item}")"
    if [[ ! -e "${resolved}" ]]; then
      DOCK_ITEMS_SKIPPED=$((DOCK_ITEMS_SKIPPED + 1))
      warn "Skipping missing Dock item: ${resolved}"
      continue
    fi

    if [[ -d "${resolved}" && "${resolved}" != *.app ]]; then
      dockutil --add "${resolved}" --view fan --display stack --sort dateadded --no-restart >/dev/null
    else
      dockutil --add "${resolved}" --no-restart >/dev/null
    fi
    DOCK_ITEMS_ADDED=$((DOCK_ITEMS_ADDED + 1))
  done <"${DOCK_ITEMS_FILE}"

  if [[ "${DOCK_ITEMS_ADDED}" -gt 0 ]]; then
    killall Dock >/dev/null 2>&1 || true
  else
    DOCK_RESULT="no items added"
    warn "No Dock items were added."
  fi
}

apply_macos_defaults() {
  defaults write -g InitialKeyRepeat -int 20
  # The old branch used 1.15 here, but KeyRepeat expects an integer.
  defaults write -g KeyRepeat -int 1
  defaults write -g ApplePressAndHoldEnabled -bool false
  defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false

  defaults write com.apple.menuextra.battery ShowPercent -string "YES"

  defaults write com.apple.finder ShowPathbar -bool true
  defaults write com.apple.finder ShowStatusBar -bool true
  defaults write com.apple.finder NewWindowTarget -string "PfHm"
  defaults write com.apple.finder QLEnableTextSelection -bool true

  defaults write com.apple.dock show-recents -bool false
  defaults write com.apple.dock mru-spaces -bool false

  defaults write com.apple.LaunchServices LSQuarantine -bool false
  defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
  defaults write com.googlecode.iterm2 PromptOnQuit -bool false
  defaults write com.apple.ActivityMonitor IconType -int 5

  killall Finder >/dev/null 2>&1 || true
  killall Dock >/dev/null 2>&1 || true
  killall "Activity Monitor" >/dev/null 2>&1 || true

  log "Log out and back in to fully apply keyboard repeat changes."
}

print_summary() {
  local ssh_key_status="missing"
  local mas_result="included"
  local dock_result="${DOCK_RESULT}"

  if [[ -f "${HOME}/.ssh/id_ed25519" ]]; then
    ssh_key_status="present"
  fi

  if [[ "${MAS_SKIPPED}" -eq 1 ]]; then
    mas_result="skipped (not signed into App Store)"
  fi

  if [[ "${DOCK_RESULT}" == "configured" ]]; then
    dock_result="configured (${DOCK_ITEMS_ADDED} added, ${DOCK_ITEMS_SKIPPED} skipped)"
  fi

  cat <<EOF

Setup complete.

Mode: ${SETUP_MODE}
Computer name: ${COMPUTER_NAME}
Git identity: ${GIT_USER_NAME} <${GIT_USER_EMAIL}>
Phases run: ${RAN_PHASES:-none}
Phases skipped: ${SKIPPED_PHASES:-none}

Checks:
  - SSH key: ${ssh_key_status}
  - GitHub CLI auth: ${GH_AUTH_RESULT}
  - Brew manifest: ${BREWFILE_USED:-not run}
  - Mac App Store installs: ${mas_result}
  - Dock: ${dock_result}

Manual follow-up that may still be needed:
  - Sign into the Mac App Store before rerunning the brew phase if mas installs were skipped.
  - Re-run with --only brew after signing into the Mac App Store if you want the mas apps installed.
  - Verify your SSH key exists in GitHub: https://github.com/settings/keys
  - Log out and back in so keyboard repeat changes fully apply.
  - Restart your shell so Homebrew, rustup, mise, and any global tool shims are loaded.
EOF
}

phase_preflight() {
  ensure_xcode_tools
  ensure_homebrew
}

phase_system() {
  configure_computer_name
}

phase_brew() {
  brew_bundle_install
}

phase_auth() {
  ensure_ssh_key
  ensure_ssh_config
  start_ssh_agent
  add_ssh_key_to_agent
  copy_ssh_key_to_clipboard
  configure_git
  ensure_github_auth
}

phase_dev() {
  install_rust
  install_mise_tools
  install_npm_global_packages
  install_uv_tools
  install_cargo_packages
  ensure_plugin_managers
  start_brew_services
}

phase_defaults() {
  apply_macos_defaults
}

phase_dock() {
  configure_dock
}

main() {
  parse_args "$@"

  require_macos
  validate_setup_mode
  brew_shellenv

  run_step preflight "Verify base macOS tooling" phase_preflight
  run_step system "Set the computer name" phase_system
  run_step brew "Install Homebrew packages and apps" phase_brew
  run_step auth "Create SSH, Git, and GitHub auth setup" phase_auth
  run_step dev "Install language tooling and developer services" phase_dev
  run_step defaults "Apply macOS defaults" phase_defaults
  run_step dock "Configure pinned Dock items" phase_dock

  if [[ "${DRY_RUN}" -eq 1 ]]; then
    log "Dry run complete."
    return
  fi

  print_summary
}

main "$@"
