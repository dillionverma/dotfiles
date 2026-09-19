# Dotfiles

> Declarative macOS setup: [nix-darwin](https://github.com/nix-darwin/nix-darwin) + [home-manager](https://github.com/nix-community/home-manager) + [nix-homebrew](https://github.com/zhaofengli/nix-homebrew), on [Determinate Nix](https://determinate.systems).

One command applies the whole machine — packages, GUI apps, fonts, macOS defaults, dock, shell, git, vim — atomically, with rollback.

## Layout

| File | Owns |
|---|---|
| `me.nix` | Who: username, full name, email, GitHub handle — the only file to edit when forking |
| `flake.nix` | Inputs (nixpkgs-unstable, nix-darwin, home-manager, nix-homebrew) and per-machine hosts via `mkDarwinHost` (`mac-mini`, `mbp`) |
| `darwin.nix` | System level: Homebrew casks + Mac App Store apps, fonts, macOS defaults, dock |
| `home.nix` | User level: CLI packages, zsh, git/gh/ssh, vim, app config files |
| `config/` | Non-Nix assets referenced from `home.nix` (ghostty, oh-my-posh theme, bat theme, vim, zed, superset) |
| `templates/devenv/` | Per-project node + postgres + redis environment (`nix flake init -t <this repo>#devenv`) |
| `scripts/repo-clone` | Clone repos into a consistent `~/src` layout (installed onto PATH by `home.nix`) |

Design notes: CLI tools come from nixpkgs; GUI apps stay Homebrew casks (self-update, Spotlight, dock icons). `brew tap` is disabled on purpose — `mutableTaps = false` means the only tap on disk is the in-repo one under `taps/`, and everything else resolves over Homebrew's API. There are no global services; databases run per-project via [devenv](https://devenv.sh).

## New machine

```bash
curl -fsSL dillion.io/setup | sh
```

Asks for the computer name, the flake host, and your password up front, then runs unattended: Xcode CLT, Determinate Nix, clone, first `darwin-rebuild switch`, ssh key, and a checklist for what needs a human. Re-runnable — finished steps are skipped.

`dillion.io/setup` is a Cloudflare Worker route on the [dillion.io](https://github.com/dillionverma/dillion.io) site that serves this repo's [`bootstrap.sh`](bootstrap.sh) from `main`. The script is safe to pipe: everything is inside `main()`, so a truncated download runs nothing, and prompts read from `/dev/tty`. `sh -c "$(curl -fsSL https://dillion.io/setup)"` works too, or clone first and run `./bootstrap.sh`.

**Before you run it:** sign into iCloud *and* the App Store in System Settings, or `masApps` (Todoist, Timery, Xcode) will be skipped. Apple Silicon only — the flake pins `aarch64-darwin`. Xcode is a 10+ GB download, so the first switch takes a while.

### Prompts and env overrides

| Prompt | Env | Default |
|---|---|---|
| Computer name | `COMPUTER_NAME` | current name |
| Flake host (`darwinConfigurations` attr) | `FLAKE_HOST` | LocalHostName, lowercased |
| — | `DOTFILES_REPO` | `dillionverma/dotfiles` (`owner/repo` or URL) |
| — | `DOTFILES_DIR` | `~/src/personal/dotfiles` |
| — | `NONINTERACTIVE=1` | take every default, never ask |

The flake host must already exist in `flake.nix`; the script prints the line to add if it doesn't. Fully unattended:

```bash
curl -fsSL dillion.io/setup | COMPUTER_NAME="studio" FLAKE_HOST=studio NONINTERACTIVE=1 sh
```

### What still needs a human

The script offers these at the end; if you skipped them:

```bash
gh auth login
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(scutil --get ComputerName)"
rustup default stable   # rustup is installed, but no toolchain is selected
```

`gh ssh-key add` registers the generated key — without it, `git`/`repo-clone` over SSH fails with `Permission denied (publickey)`. (`gh auth login` alone only covers gh's own HTTPS API, not `git`'s SSH remotes.)

Raycast owns cmd+space (Spotlight's hotkey is disabled declaratively), but macOS privacy grants can't be automated without MDM. Launch Raycast once, then grant it access in each pane:

```bash
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars"
open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
```

Then sign into Tailscale, Bitwarden, Slack, etc.; run `infisical login`; and **log out and back in** so the keyboard-repeat defaults apply.

## Make it yours

Everything personal lives in [`me.nix`](me.nix) (username, name, email, GitHub). Fork, then:

```bash
curl -fsSL dillion.io/setup | DOTFILES_REPO=you/dotfiles sh
```

Edit those four strings by hand — nothing in this repo rewrites tracked files. Machines are one `mkDarwinHost "name"` line each in `flake.nix`. Machine-specific bits (the `mac-mini` ssh alias, tailscale formula vs app) key off that host name in `home.nix` / `darwin.nix`.

## Daily use

```bash
drs                                   # rebuild + switch (alias in home.nix)
sudo darwin-rebuild --list-generations     # history (needs sudo: root owns the profile lock)
sudo darwin-rebuild switch --rollback      # undo
nix flake update                           # bump pinned inputs; commit flake.lock
```

Edit `darwin.nix` / `home.nix` / `config/*`, then `drs`. Zed settings are symlinked out-of-store, so the Zed UI writes straight into this repo.

New project with node + postgres + redis:

```bash
mkdir myapp && cd myapp
nix flake init -t ~/src/personal/dotfiles#devenv
direnv allow           # loads the shell on cd
devenv up              # starts postgres + redis, state in .devenv/state/
```
