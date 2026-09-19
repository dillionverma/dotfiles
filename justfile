# Task runner for this flake. `just` with no arguments lists everything.
#
# Determinate Nix owns the daemon here, so nix-darwin's nix.* options are off
# (nix.enable = false in darwin.nix) and there is no GC timer — `just gc` is
# the only thing that reclaims the store.

# Which darwinConfigurations attr to build. Defaults to this machine's
# LocalHostName, lowercased. Override per-invocation:
#   just host=mac-mini switch
host := env_var_or_default("FLAKE_HOST", lowercase(`scutil --get LocalHostName`))

_default:
    @just --list --unsorted

# Fail early with the exact line to add, rather than a nix eval backtrace.
_require-host:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! grep -q 'mkDarwinHost "{{ host }}"' flake.nix; then
      hosts=$(grep -o 'mkDarwinHost "[^"]*"' flake.nix | cut -d'"' -f2 | tr '\n' ' ')
      echo "error: host '{{ host }}' is not defined in flake.nix (have: ${hosts% })" >&2
      echo "  add it:        {{ host }} = mkDarwinHost \"{{ host }}\";" >&2
      echo "  or pick one:   just host=${hosts%% *} <recipe>" >&2
      exit 1
    fi

# Rebuild and activate this machine.
switch: _require-host
    sudo darwin-rebuild switch --flake .#{{ host }}

# Build without activating, then show what would change.
build: _require-host
    nix build .#darwinConfigurations.{{ host }}.system
    @nix run nixpkgs#nvd -- diff /run/current-system ./result

# Evaluate and build every host. Catches breakage before it reaches a machine.
check:
    nix flake check

# Format nix, shell and markdown (nixfmt + shfmt + prettier via treefmt).
fmt:
    nix fmt

# Bump every flake input. Commit flake.lock afterwards.
update:
    nix flake update

# Activation deliberately does not upgrade casks; do it on purpose instead.
brew-upgrade:
    brew upgrade
    brew upgrade --cask --greedy

# List system generations (the profile lock is root-owned).
generations:
    sudo darwin-rebuild --list-generations

# Roll back to the previous generation.
rollback:
    sudo darwin-rebuild switch --rollback

# Nothing else reclaims the store: Determinate ships no GC timer, and
# nix.enable = false means nix-darwin contributes none either.

# Collect garbage older than N days (default 30).
gc days="30":
    sudo nix-collect-garbage --delete-older-than {{ days }}d
    nix-collect-garbage --delete-older-than {{ days }}d
    nix store optimise
