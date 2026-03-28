#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -x "${SCRIPT_DIR}/install.sh" ]]; then
  INSTALLER_ROOT="${SCRIPT_DIR}"
elif [[ -x "${SCRIPT_DIR}/new-laptop-setup/install.sh" ]]; then
  INSTALLER_ROOT="${SCRIPT_DIR}/new-laptop-setup"
else
  printf 'Could not find install.sh relative to %s\n' "${SCRIPT_DIR}" >&2
  exit 1
fi

if [[ ! -x "${INSTALLER_ROOT}/install.sh" ]]; then
  printf 'Expected installer at %s/install.sh\n' "${INSTALLER_ROOT}" >&2
  exit 1
fi

export INSTALL_SOURCE_DIR="${INSTALLER_ROOT}"
exec "${INSTALLER_ROOT}/install.sh" "$@"
