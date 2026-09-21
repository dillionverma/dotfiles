# Dotfiles

Declarative macOS setup — packages, GUI apps, fonts, system defaults, dock, shell, git, vim — applied atomically, with rollback.

[nix-darwin](https://github.com/nix-darwin/nix-darwin) + [home-manager](https://github.com/nix-community/home-manager) + [nix-homebrew](https://github.com/zhaofengli/nix-homebrew), on [Determinate Nix](https://determinate.systems).

## Setup

```bash
curl -fsSL dillion.io/setup | sh
```

Apple Silicon only. Sign into iCloud and the App Store first, or App Store apps are skipped. Idempotent — re-run it any time. ([what it does](bootstrap.sh))

## Usage

```bash
just            # list every recipe
just switch     # rebuild + activate   (alias: drs)
just gc         # reclaim the store — nothing else does
```

Run from the repo root; `just` finds the justfile there.

## Layout

|                 |                                                            |
| --------------- | ---------------------------------------------------------- |
| `me.nix`        | Identity — the only file to edit when forking              |
| `flake.nix`     | Inputs, and one `mkDarwinHost` line per machine            |
| `darwin.nix`    | System: casks, App Store apps, fonts, macOS defaults, dock |
| `home.nix`      | User: CLI packages, zsh, git/gh/ssh, vim                   |
| `config/<app>/` | Non-Nix assets                                             |
| `theme.nix`     | Vesper palette                                             |

CLI tools come from nixpkgs; GUI apps stay Homebrew casks, resolved over brew's JSON API with no taps declared.

## Forking

Edit the four strings in [`me.nix`](me.nix), add your machine as a `mkDarwinHost` line in `flake.nix`, then:

```bash
curl -fsSL dillion.io/setup | DOTFILES_REPO=you/dotfiles sh
```
