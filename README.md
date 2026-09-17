# Dotfiles

> Declarative macOS setup: [nix-darwin](https://github.com/nix-darwin/nix-darwin) + [home-manager](https://github.com/nix-community/home-manager) + [nix-homebrew](https://github.com/zhaofengli/nix-homebrew), on [Determinate Nix](https://determinate.systems).

One command applies the whole machine — packages, GUI apps, fonts, macOS defaults, dock, shell, git, vim — atomically, with rollback.

## Layout

| File | Owns |
|---|---|
| `me.nix` | Who: username, full name, email, GitHub handle — the only file to edit when forking |
| `flake.nix` | Inputs (nixpkgs-unstable, nix-darwin, home-manager, nix-homebrew, immutable brew taps) and per-machine hosts via `mkDarwinHost` (`mac-mini`, `mbp`) |
| `darwin.nix` | System level: Homebrew casks + Mac App Store apps, fonts, macOS defaults, dock |
| `home.nix` | User level: CLI packages, zsh, git/gh/ssh, vim, app config files |
| `config/` | Non-Nix assets referenced from `home.nix` (ghostty, oh-my-posh theme, bat theme, vimrc, zed, superset) |
| `templates/devenv/` | Per-project node + postgres + redis environment (`nix flake init -t <this repo>#devenv`) |
| `scripts/repo-clone` | Clone repos into a consistent `~/src` layout (installed onto PATH by `home.nix`) |

Design notes: CLI tools come from nixpkgs; GUI apps stay Homebrew casks (self-update, Spotlight, dock icons). Brew taps are immutable flake inputs — ad-hoc `brew tap` is disabled on purpose. There are no global services; databases run per-project via [devenv](https://devenv.sh).

## New machine

```bash
curl -fsSL dillion.io/setup | sh
```

One prompt for the computer name, one for the flake host, one password; then it runs unattended: Xcode CLT, Determinate Nix, clone, first `darwin-rebuild switch`, ssh key, and a checklist for what needs a human (`gh auth login`, Raycast permissions, app sign-ins). Re-runnable. `dillion.io/setup` serves [`bootstrap.sh`](bootstrap.sh) from this repo's `main`; details in [docs/bootstrap.md](docs/bootstrap.md).

## Make it yours

Everything personal lives in [`me.nix`](me.nix) (username, name, email, GitHub). Fork, then:

```bash
curl -fsSL dillion.io/setup | DOTFILES_REPO=you/dotfiles sh
```

When the macOS user differs from `me.nix`, the script asks for your name/email/GitHub and rewrites `me.nix` (committed locally). Machines are one `mkDarwinHost "name"` line each in `flake.nix`; the script adds yours if it is missing. Machine-specific bits (the `mac-mini` ssh alias, tailscale formula vs app) key off that host name in `home.nix` / `darwin.nix`.

## Daily use

```bash
drs                                   # rebuild + switch (alias in home.nix)
darwin-rebuild --list-generations     # history
sudo darwin-rebuild switch --rollback # undo
nix flake update                      # bump pinned inputs; commit flake.lock
```

Edit `darwin.nix` / `home.nix` / `config/*`, then `drs`. Zed settings are symlinked out-of-store, so the Zed UI writes straight into this repo.
