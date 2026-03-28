# New Laptop Setup

This folder contains a macOS-first bootstrap flow for setting up a fresh laptop.

## Entry points
- Local: `~/setup.sh`
- Hosted: `curl -fsSL https://dillion.io/install.sh | bash`

The hosted `install.sh` should serve the bootstrap script in this folder and make the rest of the installer files available under:

- `https://dillion.io/new-laptop-setup/Brewfile.core`
- `https://dillion.io/new-laptop-setup/Brewfile.full`
- `https://dillion.io/new-laptop-setup/README.md`
- `https://dillion.io/new-laptop-setup/scripts/setup-macos.sh`
- `https://dillion.io/new-laptop-setup/manifests/npm-global-packages.txt`
- `https://dillion.io/new-laptop-setup/manifests/uv-tools.txt`
- `https://dillion.io/new-laptop-setup/manifests/cargo-packages.txt`
- `https://dillion.io/new-laptop-setup/manifests/dock-items.txt`

If you want to host the support files somewhere else, override:

- `INSTALL_BASE_URL=https://example.com/new-laptop-setup`

## Common usage
- Full install: `~/setup.sh`
- Core CLI-only install: `SETUP_MODE=core ~/setup.sh`
- Dry run: `~/setup.sh --dry-run`
- List phases: `~/setup.sh --list-phases`
- Only install brew packages: `~/setup.sh --only brew`
- Only configure the Dock: `~/setup.sh --only dock`
- Skip auth and Mac App Store setup: `~/setup.sh --skip auth`

## Environment overrides
- `COMPUTER_NAME`
- `GIT_USER_NAME`
- `GIT_USER_EMAIL`
- `SETUP_MODE`

`SETUP_MODE` values:
- `full` installs formulae, casks, and App Store apps where available.
- `core` installs formulae only.

## Managed manifests
- `Brewfile.core`: CLI and service packages only
- `Brewfile.full`: core packages plus apps, fonts, and App Store apps
- `manifests/npm-global-packages.txt`: global Node packages installed after `nvm` + Node LTS
- `manifests/uv-tools.txt`: Python-adjacent tools installed via `uv tool install`
- `manifests/cargo-packages.txt`: Rust tools installed via `cargo install --locked`
- `manifests/dock-items.txt`: pinned Dock items, added in order if present

Example:

```bash
COMPUTER_NAME=mbp \
GIT_USER_NAME="Dillion Verma" \
GIT_USER_EMAIL="hello@dillion.io" \
~/setup.sh
```
