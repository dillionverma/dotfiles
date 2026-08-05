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
4. Installs [Determinate Nix](https://determinate.systems) (flakes enabled, survives macOS upgrades)
5. Clones this repo to `~/src/personal/dotfiles`
6. Moves aside any stock `/etc/zshrc`/`/etc/bashrc` (nix-darwin refuses to overwrite files it doesn't recognize)
7. Runs the first `darwin-rebuild switch` — installs Homebrew (via nix-homebrew), all casks and Mac App Store apps, every CLI tool, fonts, macOS defaults, and the dock

## Before running

- **Sign into iCloud + the App Store** in System Settings — `masApps` (Todoist, Timery, Xcode) fail to install otherwise. Xcode is a 10+ GB download; the first switch takes a while.

## Manual tail (interactive, can't be declarative)

```bash
ssh-keygen -t ed25519 -C hello@dillion.io -f ~/.ssh/id_ed25519
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
gh auth login          # upload the ssh key during auth
rustup default stable
```

Then: sign into Tailscale, Bitwarden, Slack, etc.; `infisical login`; **log out and back in** so the keyboard-repeat defaults apply.

## Daily driving

```bash
drs                    # alias: sudo darwin-rebuild switch --flake ~/src/personal/dotfiles#mbp
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
