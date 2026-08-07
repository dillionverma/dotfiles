# Dotfiles

> Declarative macOS setup: [nix-darwin](https://github.com/nix-darwin/nix-darwin) + [home-manager](https://github.com/nix-community/home-manager) + [nix-homebrew](https://github.com/zhaofengli/nix-homebrew), on [Determinate Nix](https://determinate.systems).

One command applies the whole machine — packages, GUI apps, fonts, macOS defaults, dock, shell, git, vim — atomically, with rollback.

## Layout

| File | Owns |
|---|---|
| `flake.nix` | Inputs (nixpkgs-unstable, nix-darwin, home-manager, nix-homebrew, immutable brew taps) and per-machine hosts via `mkDarwinHost` (currently `mac-mini`) |
| `darwin.nix` | System level: Homebrew casks + Mac App Store apps, fonts, macOS defaults, dock |
| `home.nix` | User level: CLI packages, zsh, git/gh/ssh, vim, app config files |
| `config/` | Non-Nix assets referenced from `home.nix` (ghostty, oh-my-posh theme, vimrc, zed, superset) |
| `templates/devenv/` | Per-project node + postgres + redis environment (`nix flake init -t <this repo>#devenv`) |
| `scripts/repo-clone` | Clone repos into a consistent `~/src` layout (installed onto PATH by `home.nix`) |
| `skills/` | Agent skills |

Design notes: CLI tools come from nixpkgs; GUI apps stay Homebrew casks (self-update, Spotlight, dock icons). Brew taps are immutable flake inputs — ad-hoc `brew tap` is disabled on purpose. There are no global services; databases run per-project via [devenv](https://devenv.sh).

## New machine

```bash
curl -fsSL https://raw.githubusercontent.com/dillionverma/dotfiles/main/bootstrap.sh | bash
```

Details and the manual tail (ssh key, `gh auth login`, App Store sign-in): [docs/bootstrap.md](docs/bootstrap.md).

## Daily use

```bash
drs                                   # rebuild + switch (alias in home.nix)
darwin-rebuild --list-generations     # history
sudo darwin-rebuild switch --rollback # undo
nix flake update                      # bump pinned inputs; commit flake.lock
```

Edit `darwin.nix` / `home.nix` / `config/*`, then `drs`. Zed settings are symlinked out-of-store, so the Zed UI writes straight into this repo.
