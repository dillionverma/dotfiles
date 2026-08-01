# System-level configuration (nix-darwin). User-level config lives in home.nix.
{ pkgs, inputs, ... }:

{
  imports = [
    inputs.home-manager.darwinModules.home-manager
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
}
