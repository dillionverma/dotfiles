# Dotfiles

> Personal dotfiles, settings, skills, and bootstrap scripts for a new macOS laptop.

## Table of Contents

- [Background](#background)
- [Install](#install)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Background

This repo is the source of truth for my local machine setup. It holds the scripts and manifests I use to keep shell tooling, package installs, machine defaults, and Codex skills in one place.

The bootstrap installer is a convenience layer on top of that setup. It is primarily for getting a new macOS laptop into a usable state quickly by installing packages, configuring Git and SSH, setting macOS defaults, and rebuilding the Dock.

## Install

Hosted bootstrap:

```bash
curl -fsSL https://dillion.io/install.sh | bash
```

Local checkout:

```bash
git clone https://github.com/dillionverma/dotfiles.git
cd dotfiles
./setup.sh
```

The installer is macOS-only, and some phases require an interactive terminal.

## Usage

Use the repo as the home for machine setup and bootstrap automation. The main entrypoint is `./setup.sh`.

Common runs:

```bash
./setup.sh
SETUP_MODE=core ./setup.sh
./setup.sh --dry-run
./setup.sh --list-phases
./setup.sh --only brew,dev
./setup.sh --skip auth
```

Available phases:

```text
preflight
system
brew
auth
dev
defaults
dock
```

`SETUP_MODE=full` installs CLI tools, desktop apps, fonts, and App Store apps. `SETUP_MODE=core` installs CLI tools and services only.

The installer sets up:

- Homebrew packages from `Brewfile.core` or `Brewfile.full`
- Git, SSH, and `gh` authentication
- Rust, `nvm` + Node LTS, npm globals, `uv` tools, and cargo packages
- PostgreSQL and Redis via Homebrew
- macOS defaults and Dock items from `manifests/dock-items.txt`

Other repo contents include:

- `skills/` for Codex skills
- `manifests/` for package and Dock manifests
- `scripts/` for machine setup and repo management helpers

Useful environment variables:

- `SETUP_MODE`
- `COMPUTER_NAME`
- `GIT_USER_NAME`
- `GIT_USER_EMAIL`
- `INSTALL_BASE_URL`

Example:

```bash
COMPUTER_NAME=work-mbp SETUP_MODE=core ./setup.sh
```

The repo also includes `scripts/repo-clone` for cloning repositories into a consistent `~/src` layout:

```bash
scripts/repo-clone work acme/api
scripts/repo-clone personal dillion/dotfiles
scripts/repo-clone --print-shell-function
```

Track shell config from this repo by linking the checked-in zsh config into your home directory:

```bash
./scripts/link-dotfiles.sh
```

## Contributing

No `CONTRIBUTING.md` file is checked into this repo yet.

## License

No license file is checked into this repo yet.
