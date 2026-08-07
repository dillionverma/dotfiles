# New Mac: zero to configured

## One command

```bash
curl -fsSL https://raw.githubusercontent.com/dillionverma/dotfiles/main/bootstrap.sh | bash
```

Or clone first and run `./bootstrap.sh`. The script is idempotent and runs end-to-end in one pass: it asks for the computer name and your password once up front, then everything else is unattended.

## What it does

1. Prompts for the computer name (default: current name) and sets it via `scutil` — per-machine, so rebuilds never rename the machine. Skip the prompt with `COMPUTER_NAME=studio ./bootstrap.sh`.
2. Primes `sudo` once and keeps it alive for the whole run — a single password prompt.
3. Installs Xcode Command Line Tools headlessly via `softwareupdate` (falls back to the GUI installer and waits for it — no re-run needed)
4. Accepts the Xcode license if a previous run already installed Xcode (a postActivation hook in darwin.nix covers the first-install case, when Xcode lands mid-switch via masApps)
5. Installs [Determinate Nix](https://determinate.systems) (flakes enabled, survives macOS upgrades)
6. Clones this repo to `~/src/personal/dotfiles`
7. Asks which flake host to build (the `mkDarwinHost` entries in `flake.nix`; skip the prompt with `FLAKE_ATTR=<host>`) — the name drives the flake attr and the `drs` alias. New Mac = one new `mkDarwinHost "name"` line in `flake.nix`
8. Moves aside any stock `/etc/zshrc`/`/etc/bashrc` (nix-darwin refuses to overwrite files it doesn't recognize)
9. Runs the first `darwin-rebuild switch` — installs Homebrew (via nix-homebrew), all casks and Mac App Store apps, every CLI tool, fonts, macOS defaults (including disabling Spotlight's cmd+space and pointing Raycast at it), and the dock
10. Generates `~/.ssh/id_ed25519` (no passphrase; the keychain guards it) and adds it to the macOS keychain
11. Sets `rustup default stable` if no toolchain is configured

## Before running

- **Sign into iCloud + the App Store** in System Settings — `masApps` (Todoist, Timery, Xcode) fail to install otherwise. Xcode is a 10+ GB download; the first switch takes a while.

## Manual tail (interactive, can't be declarative)

```bash
gh auth login                              # authenticate gh
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(scutil --get ComputerName)"
```

`gh ssh-key add` registers the generated key on GitHub — without it, `git`/`repo-clone`
over SSH fails with `Permission denied (publickey)`. (`gh auth login` alone only covers
gh's own HTTPS API, not `git`'s SSH remotes.)

### Raycast permissions

Raycast owns cmd+space (Spotlight's hotkey is disabled declaratively), but
macOS privacy (TCC) grants can't be automated without MDM. Launch Raycast
once, then grant access in each pane:

```bash
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars"
open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
```

Then: sign into Tailscale, Bitwarden, Slack, etc.; `infisical login`; **log out and back in** so the keyboard-repeat defaults and the cmd+space handoff apply.

## Daily driving

```bash
drs                    # alias: sudo darwin-rebuild switch --flake ~/src/personal/dotfiles#<host>
darwin-rebuild --list-generations   # atomic history
sudo darwin-rebuild switch --rollback
nix flake update       # bump pinned inputs (commit flake.lock separately)
```

New project with node + postgres + redis:

```bash
mkdir myapp && cd myapp
nix flake init -t ~/src/personal/dotfiles#devenv
direnv allow           # loads the shell on cd
devenv up              # starts postgres + redis, state in .devenv/state/
```
