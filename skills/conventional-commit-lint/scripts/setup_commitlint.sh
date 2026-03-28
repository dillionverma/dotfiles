#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  setup_commitlint.sh /path/to/repo

Installs local commitlint dependencies, writes commitlint.config.cjs if needed,
and adds a .git/hooks/commit-msg hook.
EOF
}

detect_package_manager() {
  if [[ -f "pnpm-lock.yaml" ]]; then
    printf '%s\n' "pnpm"
  elif [[ -f "package-lock.json" ]]; then
    printf '%s\n' "npm"
  elif [[ -f "yarn.lock" ]]; then
    printf '%s\n' "yarn"
  elif [[ -f "bun.lockb" || -f "bun.lock" ]]; then
    printf '%s\n' "bun"
  else
    printf '%s\n' "npm"
  fi
}

install_deps() {
  local pm="$1"

  case "${pm}" in
    pnpm)
      pnpm add -D @commitlint/cli @commitlint/config-conventional
      ;;
    yarn)
      yarn add -D @commitlint/cli @commitlint/config-conventional
      ;;
    bun)
      bun add -d @commitlint/cli @commitlint/config-conventional
      ;;
    npm)
      npm install -D @commitlint/cli @commitlint/config-conventional
      ;;
    *)
      printf 'Unsupported package manager: %s\n' "${pm}" >&2
      exit 1
      ;;
  esac
}

write_config() {
  if [[ -f "commitlint.config.cjs" || -f "commitlint.config.js" || -f ".commitlintrc" || -f ".commitlintrc.json" ]]; then
    return
  fi

  cat > commitlint.config.cjs <<'EOF'
module.exports = {
  extends: ['@commitlint/config-conventional'],
};
EOF
}

write_hook() {
  local hook_path=".git/hooks/commit-msg"

  if [[ -f "${hook_path}" ]]; then
    printf 'Existing commit-msg hook found at %s. Review it manually before overwriting.\n' "${hook_path}" >&2
    exit 1
  fi

  cat > "${hook_path}" <<'EOF'
#!/usr/bin/env sh
set -eu

if [ -x "./node_modules/.bin/commitlint" ]; then
  exec ./node_modules/.bin/commitlint --edit "$1"
fi

if command -v commitlint >/dev/null 2>&1; then
  exec commitlint --edit "$1"
fi

echo "commitlint not found" >&2
exit 1
EOF

  chmod +x "${hook_path}"
}

main() {
  local repo_path="${1:-}"
  local pm

  [[ -n "${repo_path}" ]] || {
    usage >&2
    exit 1
  }

  cd "${repo_path}"

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    printf 'Not a git repository: %s\n' "${repo_path}" >&2
    exit 1
  }

  [[ -f "package.json" ]] || {
    printf 'package.json not found in %s. Initialize the repo with npm/pnpm/yarn first.\n' "${repo_path}" >&2
    exit 1
  }

  pm="$(detect_package_manager)"
  install_deps "${pm}"
  write_config
  write_hook
}

main "$@"
