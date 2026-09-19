{
  description = "Dillion's macOS setup: nix-darwin + home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Deliberately does NOT pin homebrew-core/homebrew-cask. nix-homebrew sets
    # HOMEBREW_NO_INSTALL_FROM_API=1 whenever homebrew-core is a pinned tap,
    # which forces brew off its JSON API and onto the full git-tap code path —
    # two enormous checkouts to clone and update. Unpinned, brew resolves
    # formulae and casks over the API. mutableTaps = false still holds in
    # darwin.nix, so ad-hoc `brew tap` stays disabled and the only tap on disk
    # is the in-repo one. brew itself comes from nix-homebrew's own pin.
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs =
    inputs@{ nix-darwin, ... }:
    let
      # Who this machine belongs to (username, name, email). One file; see me.nix.
      me = import ./me.nix;

      # One entry per machine; the attr name flows into the drs alias and
      # bootstrap.sh (which prompts for it and appends a line here for a new
      # Mac). The computer name itself is set once by bootstrap.sh via scutil,
      # not managed here.
      mkDarwinHost =
        hostName:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs hostName me; };
          modules = [ ./darwin.nix ];
        };
    in
    {
      darwinConfigurations = {
        mac-mini = mkDarwinHost "mac-mini";
        mbp = mkDarwinHost "mbp";
      };

      # Scaffold a project: nix flake init -t ~/src/personal/dotfiles#devenv
      templates.devenv = {
        path = ./templates/devenv;
        description = "Project devshell: node + pnpm + postgres + redis (devenv)";
      };
    };
}
