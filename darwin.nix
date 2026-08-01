# System-level configuration (nix-darwin). User-level config lives in home.nix.
{ pkgs, config, inputs, ... }:

{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  ## Core --------------------------------------------------------------------

  # Determinate Nix owns the Nix installation, daemon, and GC; nix-darwin must
  # not manage it. Do not set any other nix.* option — assertions will fire.
  nix.enable = false;

  system.stateVersion = 6;
  system.primaryUser = "dillion";
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # Replaces the scutil calls from the v1 `system` phase.
  networking = {
    computerName = "mbp";
    hostName = "mbp";
    localHostName = "mbp";
  };

  users.users.dillion.home = "/Users/dillion";

  # sudo via Touch ID (`darwin-rebuild switch` needs sudo).
  security.pam.services.sudo_local.touchIdAuth = true;

  # Nix-aware /etc/zshrc; user zsh config is in home.nix.
  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];

  ## Home Manager ------------------------------------------------------------

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs; };
    users.dillion = import ./home.nix;
  };

  ## Homebrew ----------------------------------------------------------------
  # nix-homebrew pins the Homebrew installation itself and makes taps
  # immutable flake inputs; the homebrew module below declares what is
  # installed. GUI apps stay casks on purpose: self-update, Spotlight
  # indexing, and the dock question-mark bug (nix-darwin#1250) all favor
  # /Applications over the nix store.

  nix-homebrew = {
    enable = true;
    enableRosetta = false;
    user = "dillion";
    # Adopt the existing /opt/homebrew installation on first switch.
    autoMigrate = true;
    # Taps are read-only flake inputs; ad-hoc `brew tap` is disabled by design.
    mutableTaps = false;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
  };

  homebrew = {
    enable = true;
    # Must mirror nix-homebrew.taps exactly, or activation tries to modify
    # the read-only tap checkouts and fails.
    taps = builtins.attrNames config.nix-homebrew.taps;

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      # Migration phase 5 (docs/migration.md): flip to "uninstall" once the
      # brew-to-nix package moves are verified. "none" keeps undeclared
      # formulae (postgres, redis, mise, ...) installed until then.
      cleanup = "none";
    };

    # Everything CLI moved to nixpkgs (home.nix). What remains, and why:
    brews = [
      "mas" # brew bundle shells out to it for masApps
      "googleworkspace-cli" # not packaged in nixpkgs
      "mint" # Swift build is heavy/fragile in nixpkgs on darwin
      "thefuck" # upstream-abandoned; nixpkgs build unreliable
    ];

    casks = [
      "beeper"
      "bitwarden"
      "claude"
      "claude-code"
      "codex"
      "codex-app"
      "codexbar"
      "discord"
      "figma"
      "gcloud-cli"
      "ghostty"
      "gpg-suite"
      "handbrake-app"
      "hiddenbar"
      "linear"
      "medis"
      "notion"
      "notion-calendar"
      "obs"
      "orbstack"
      "raycast"
      "rectangle"
      "slack"
      "spotify"
      "superset"
      "t3-code"
      "tailscale-app" # also provides the tailscale CLI + daemon; no formula needed
      "thebrowsercompany-dia"
      "transmission"
      "vlc"
      "zed"
    ];

    # Requires being signed into the App Store.
    masApps = {
      Todoist = 585829637;
      Timery = 1425368544;
      Xcode = 497799835;
    };
  };

  ## Fonts -------------------------------------------------------------------
  # Replaces the three font casks; installed to /Library/Fonts/Nix Fonts.
  fonts.packages = with pkgs; [
    fira-code
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];
}
