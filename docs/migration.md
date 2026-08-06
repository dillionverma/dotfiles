# Migrating the current machine from v1 (bash + Brewfile) to v2 (Nix)

One-time runbook for the machine that ran the v1 setup. Delete this file when done.
Run each phase in order; each ends with a working system, so you can stop at any point.

Pre-flight (already verified ✅): login shell is `/bin/zsh` (not brew zsh — if it
ever were, `chsh -s /bin/zsh` FIRST, because phase 5 uninstalls brew's zsh).

## Phase A — snapshot

```bash
brew bundle dump --file ~/brew-snapshot.txt --force   # rollback reference
pg_dumpall > ~/pg-backup-$(date +%F).sql              # if any postgres data matters
```

## Phase B — install Nix + first switch

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
# open a new shell
cd ~/src/personal/dotfiles
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin       # if nix-darwin complains about it
```

Remove the v1 symlinks home-manager will own (backups exist in the repo; `backupFileExtension = "hm-backup"` catches stragglers):

```bash
rm -f ~/.zshrc ~/.vimrc ~/.gitconfig ~/.vim/colors/vesper.vim \
      ~/.config/bat/config ~/.config/git/ignore ~/.config/ghostty/config \
      ~/.config/ohmyposh/vesper.omp.json ~/.config/zed/settings.json
# delete any stray brew-shellenv line:
grep -n shellenv ~/.zprofile 2>/dev/null
```

First switch (generates flake.lock — commit it):

```bash
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#mac-mini
git add flake.lock && git commit -m "chore: lock flake inputs"
```

If a nixpkgs attr fails to evaluate (candidates flagged in advance: none expected —
`thefuck`/`mint` were left on brew), fix the attr name and re-switch.

## Phase C — verify (open a NEW terminal first)

```bash
readlink ~/.zshrc                                   # -> /nix/store/...
which rg fd node bun tsc ruff cargo-nextest git vim # -> /etc/profiles/per-user/dillion/bin
echo $PATH                                          # nix profiles BEFORE /opt/homebrew
git config credential."https://github.com".helper   # -> nix-store gh, not /opt/homebrew
defaults read NSGlobalDomain KeyRepeat              # -> 1
defaults read com.apple.dock show-recents           # -> 0
brew tap                                            # exactly homebrew/core + homebrew/cask
mas list                                            # 3 apps (App Store signed in)
```

Also: oh-my-posh vesper prompt renders; fzf Ctrl-R works; `vim` has gitgutter + vesper
colors; Dock shows the 8 pinned apps + Downloads with **no question marks**; Ghostty
font still renders (nix fonts replaced the font casks). Log out/in for key repeat.

## Phase D — move projects off global services

For each project that used the global postgres/redis:

```bash
cd <project>
nix flake init -t ~/src/personal/dotfiles#devenv
direnv allow
devenv up            # then restore data: psql $DATABASE_URL < dump.sql
```

Then stop the globals:

```bash
brew services stop redis postgresql@18
brew services list   # empty
```

## Phase E — flip cleanup, let brew shed the migrated formulae

In `darwin.nix`, set `homebrew.onActivation.cleanup = "uninstall"`, then `drs`.
Everything not declared (postgres, redis, mise, dockutil, the 30 migrated CLI
formulae, old taps) is uninstalled. Verify:

```bash
brew list --formula        # exactly: mas googleworkspace-cli mint thefuck
which git zsh vim tmux     # all nix paths
```

Remove dead state:

```bash
rm -rf ~/.local/share/mise ~/.config/mise ~/.local/state/mise \
       ~/.zgen ~/.tmux/plugins/tpm ~/.vim/bundle ~/.local/share/zsh
```

## Phase F — final smoke test

Reboot. Open Ghostty: prompt, aliases, fzf, zoxide, direnv all work. `drs` succeeds.
`gh auth status` + a real `git push`. Scaffold a throwaway devenv project; `psql`
and `redis-cli` connect. Then delete this file.
