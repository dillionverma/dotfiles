# Dotfiles

This repo is the source for my macOS laptop bootstrap and local setup manifests.

The public installer is hosted from the `dillionverma.com` repo and exposed at:

- `https://dillion.io/install.sh`
- `https://dillion.io/install/...`

## Local usage
- Full install: `~/src/dotfiles/setup.sh`
- Core CLI-only install: `SETUP_MODE=core ~/src/dotfiles/setup.sh`
- Dry run: `~/src/dotfiles/setup.sh --dry-run`
- List phases: `~/src/dotfiles/setup.sh --list-phases`
- Only install brew packages: `~/src/dotfiles/setup.sh --only brew`
- Only configure the Dock: `~/src/dotfiles/setup.sh --only dock`
- Skip auth and Mac App Store setup: `~/src/dotfiles/setup.sh --skip auth`

## Hosted usage
```bash
curl -fsSL https://dillion.io/install.sh | bash
```

If the support files live somewhere else, override:

```bash
INSTALL_BASE_URL=https://example.com/install curl -fsSL https://example.com/install.sh | bash
```

## Structure
- `setup.sh`: local wrapper for running the installer from this repo
- `install.sh`: hosted bootstrap entrypoint
- `scripts/setup-macos.sh`: main macOS installer
- `Brewfile.core`: CLI and service packages only
- `Brewfile.full`: core packages plus apps, fonts, and App Store apps
- `manifests/npm-global-packages.txt`: global Node packages installed after `nvm` + Node LTS
- `manifests/uv-tools.txt`: Python-adjacent tools installed via `uv tool install`
- `manifests/cargo-packages.txt`: Rust tools installed via `cargo install --locked`
- `manifests/dock-items.txt`: pinned Dock items, added in order if present

## Environment overrides
- `COMPUTER_NAME`
- `GIT_USER_NAME`
- `GIT_USER_EMAIL`
- `SETUP_MODE`
- `INSTALL_BASE_URL`

`SETUP_MODE` values:
- `full` installs formulae, casks, and App Store apps where available
- `core` installs formulae only
