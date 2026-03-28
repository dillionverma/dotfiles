#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  lint_commit_message.sh "feat(api): add retries"
  lint_commit_message.sh --edit .git/COMMIT_EDITMSG
EOF
}

resolve_commitlint() {
  if [[ -x "./node_modules/.bin/commitlint" ]]; then
    printf '%s\n' "./node_modules/.bin/commitlint"
    return 0
  fi

  if command -v commitlint >/dev/null 2>&1; then
    command -v commitlint
    return 0
  fi

  printf 'commitlint not found. Install @commitlint/cli locally in the repo or globally.\n' >&2
  exit 1
}

main() {
  local commitlint_bin

  [[ $# -gt 0 ]] || {
    usage >&2
    exit 1
  }

  case "${1:-}" in
    --help|-h)
      usage
      ;;
    --edit)
      commitlint_bin="$(resolve_commitlint)"
      [[ $# -eq 2 ]] || {
        usage >&2
        exit 1
      }
      "${commitlint_bin}" --edit "$2"
      ;;
    *)
      commitlint_bin="$(resolve_commitlint)"
      [[ $# -eq 1 ]] || {
        usage >&2
        exit 1
      }
      printf '%s\n' "$1" | "${commitlint_bin}"
      ;;
  esac
}

main "$@"
