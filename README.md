# Dotfiles

macOS bootstrap and setup scripts for a fresh laptop.

## Install
```bash
curl -fsSL https://dillion.io/install.sh | bash
```

## Local usage
- Full install: `./setup.sh`
- Core CLI-only install: `SETUP_MODE=core ./setup.sh`
- Dry run: `./setup.sh --dry-run`
- List phases: `./setup.sh --list-phases`
- Only install brew packages: `./setup.sh --only brew`
- Only configure the Dock: `./setup.sh --only dock`
- Skip auth and Mac App Store setup: `./setup.sh --skip auth`

## What it sets up
- Homebrew packages and apps
- Git, SSH, and GitHub CLI auth
- Node, Python, and Rust tooling
- macOS defaults
- Dock layout

## Structure
- `setup.sh`: local wrapper
- `install.sh`: bootstrap entrypoint
- `scripts/setup-macos.sh`: main macOS installer
- `Brewfile.core`: CLI and service packages
- `Brewfile.full`: apps, fonts, and App Store installs
- `manifests/`: extra package and Dock manifests

## Configuration
- `COMPUTER_NAME`
- `GIT_USER_NAME`
- `GIT_USER_EMAIL`
- `SETUP_MODE`
- `INSTALL_BASE_URL`

`SETUP_MODE`:
- `full`: formulae, casks, and App Store apps
- `core`: formulae only

To point the bootstrap at a different host:

```bash
INSTALL_BASE_URL=https://example.com/install curl -fsSL https://example.com/install.sh | bash
```
