# New Mac: zero to configured

## One command

```bash
curl -fsSL dillion.io/setup | sh
```

`dillion.io/setup` is a Cloudflare Worker route on the [dillion.io](https://github.com/dillionverma/dillion.io) site that serves this repo's [`bootstrap.sh`](../bootstrap.sh) from `main` (see that repo's `docs/deploy.md`); plain `http://` is redirected to `https://` and `-L` follows it. The script is safe to pipe: everything is inside `main()`, so a truncated download runs nothing, and prompts read from `/dev/tty`. `sh -c "$(curl -fsSL https://dillion.io/setup)"` works too. Or clone first and run `./bootstrap.sh`.

The script is POSIX `sh`, idempotent, and runs end-to-end in one pass: it asks two questions and your password up front, then everything else is unattended. Re-run it any time; finished steps are skipped.

## What it does

| # | Step | Skipped when |
|---|---|---|
| 1 | Prime `sudo` and keep it alive (single password prompt) | — |
| 2 | Xcode Command Line Tools, headless via `softwareupdate` (GUI fallback, waits) | already installed |
| 3 | Computer name via `scutil` (per-machine; rebuilds never rename) | already set |
| 4 | [Determinate Nix](https://determinate.systems) | `nix` on PATH |
| 5 | Clone this repo to `~/src/personal/dotfiles`; add the flake host to `flake.nix` if new; personalize `me.nix` if the macOS user differs | already done |
| 6 | First `darwin-rebuild switch`: Homebrew (via nix-homebrew), casks, Mac App Store apps, CLI tools, fonts, macOS defaults, dock | — (always runs; no-op if unchanged) |
| 7 | `~/.ssh/id_ed25519` (no passphrase, keychain-guarded), added to the agent | key exists |
| 8 | `rustup default stable` | toolchain configured |

Then a checklist. When interactive it offers to run `gh auth login`, register the ssh key on GitHub, and open the Raycast privacy panes.

## Prompts and env overrides

| Prompt | Env | Default |
|---|---|---|
| Computer name | `COMPUTER_NAME` | current name |
| Flake host (`darwinConfigurations` attr) | `FLAKE_HOST` | LocalHostName, lowercased |
| Full name / email / GitHub (only when `me.nix` is for someone else) | `FULL_NAME`, `EMAIL`, `GITHUB_USER` | macOS account name |
| — | `DOTFILES_REPO` | `dillionverma/dotfiles` (`owner/repo` or URL) |
| — | `DOTFILES_DIR` | `~/src/personal/dotfiles` |
| — | `NONINTERACTIVE=1` | take every default, never ask |

Fully unattended example:

```bash
curl -fsSL dillion.io/setup | COMPUTER_NAME="studio" FLAKE_HOST=studio NONINTERACTIVE=1 sh
```

## Before running

- **Sign into iCloud + the App Store** in System Settings — `masApps` (Todoist, Timery, Xcode) fail to install otherwise. The script warns if iCloud is not signed in. Xcode is a 10+ GB download; the first switch takes a while.
- Apple Silicon only (the flake pins `aarch64-darwin`).

## Manual tail (interactive, can't be declarative)

The script offers these at the end; if you skipped them:

```bash
gh auth login
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(scutil --get ComputerName)"
```

`gh ssh-key add` registers the generated key on GitHub — without it, `git`/`repo-clone` over SSH fails with `Permission denied (publickey)`. (`gh auth login` alone only covers gh's own HTTPS API, not `git`'s SSH remotes.)

### Raycast permissions

Raycast owns cmd+space (Spotlight's hotkey is disabled declaratively), but macOS privacy (TCC) grants can't be automated without MDM. Launch Raycast once, then grant access in each pane:

```bash
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars"
open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
```

Then: sign into Tailscale, Bitwarden, Slack, etc.; `infisical login`; **log out and back in** so the keyboard-repeat defaults and the cmd+space handoff apply.

## After setup

Daily use (`drs`, rollback, `nix flake update`) and forking (`me.nix`, `DOTFILES_REPO=`) are covered in the [README](../README.md).

New project with node + postgres + redis:

```bash
mkdir myapp && cd myapp
nix flake init -t ~/src/personal/dotfiles#devenv
direnv allow           # loads the shell on cd
devenv up              # starts postgres + redis, state in .devenv/state/
```
