# Dotfiles

> Declarative macOS setup: [nix-darwin](https://github.com/nix-darwin/nix-darwin) + [home-manager](https://github.com/nix-community/home-manager) + [nix-homebrew](https://github.com/zhaofengli/nix-homebrew), on [Determinate Nix](https://determinate.systems).

One command applies the whole machine — packages, GUI apps, fonts, macOS defaults, dock, shell, git, vim — atomically, with rollback.

## Layout

| File                 | Owns                                                                      |
| -------------------- | ------------------------------------------------------------------------- |
| `me.nix`             | Username, name, email, GitHub handle — the only file to edit when forking |
| `flake.nix`          | Inputs, and one `mkDarwinHost` line per machine (`mac-mini`, `mbp`)       |
| `darwin.nix`         | System: Homebrew casks, Mac App Store apps, fonts, macOS defaults, dock   |
| `home.nix`           | User: CLI packages, zsh, git/gh/ssh, vim, app config                      |
| `config/<app>/`      | Non-Nix assets referenced from `home.nix`                                 |
| `theme.nix`          | The Vesper palette, shared by anything themed from Nix                    |
| `justfile`           | Task runner                                                               |
| `scripts/repo-clone` | Clone repos into a consistent `~/src` layout                              |

CLI tools come from nixpkgs; GUI apps stay Homebrew casks (self-update, Spotlight, dock icons). No taps are declared and `mutableTaps = false`, so brew resolves formulae and casks over its JSON API and ad-hoc `brew tap` is disabled. No global services — databases run per-project via [devenv](https://devenv.sh).

## New machine

```bash
curl -fsSL dillion.io/setup | sh
```

Asks for a computer name, a flake host, and your password, then runs unattended: Xcode CLT, Determinate Nix, clone, first switch, ssh key. Idempotent — re-run it any time.

Apple Silicon only. Sign into iCloud **and** the App Store first, or `masApps` are skipped. The flake host must already exist in `flake.nix`; the script prints the line to add if it doesn't.

Overrides: `COMPUTER_NAME`, `FLAKE_HOST`, `DOTFILES_REPO`, `DOTFILES_DIR`, `NONINTERACTIVE=1`.

It ends with a checklist of what can't be declarative — `gh auth login`, registering the ssh key, Raycast's privacy grants, app sign-ins, `rustup default stable`, and a logout/login for the keyboard defaults.

<details>
<summary>How <code>dillion.io/setup</code> works</summary>

A Cloudflare Worker route on the [dillion.io](https://github.com/dillionverma/dillion.io) site serves [`bootstrap.sh`](bootstrap.sh) from `main`. Safe to pipe: everything is inside `main()`, so a truncated download runs nothing, and prompts read from `/dev/tty`. `sh -c "$(curl -fsSL https://dillion.io/setup)"` works too, or clone first and run `./bootstrap.sh`.

</details>

## Daily use

```bash
just                 # list recipes
just switch          # rebuild + activate   (alias: drs)
just build           # build without activating, then nvd-diff against the running system
just check           # evaluates and builds BOTH hosts
just fmt             # nixfmt + shfmt + prettier
just update          # bump flake inputs; commit flake.lock
just gc              # collect garbage older than 30 days (just gc 7 for a week)
just generations     # history
just rollback        # undo
just brew-upgrade    # casks are deliberately not upgraded during activation
```

Run these from the repo — `just` looks for the justfile in the current directory and its parents. The host comes from `LocalHostName`; override with `just host=mac-mini switch`.

**Nothing else garbage-collects.** Determinate ships no GC timer and `nix.enable = false` means nix-darwin contributes none, so `just gc` is the only thing that reclaims the store.

Edit `darwin.nix` / `home.nix` / `config/*`, then `just switch`. Zed settings are symlinked out-of-store, so the Zed UI writes straight into this repo.

## Forking

Everything personal is four strings in [`me.nix`](me.nix); edit them by hand, since nothing here rewrites tracked files. Add your machine as one `mkDarwinHost` line in `flake.nix`.

```bash
curl -fsSL dillion.io/setup | DOTFILES_REPO=you/dotfiles sh
```
