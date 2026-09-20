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
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      ...
    }:
    let
      # Every host here is Apple Silicon; darwin.nix pins the same platform.
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (nixpkgs) lib;

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

      # `nix fmt`. nixfmt is the official Nix formatter, but it takes one file
      # at a time and `nix fmt` hands the formatter a directory — nixfmt-tree
      # is the treefmt wrapper that bridges that, with no extra flake input.
      # prettier is limited to markdown on purpose: the JSON here is either
      # generated (flake.lock) or JSONC with comments (config/zed).
      formatter.${system} = pkgs.nixfmt-tree.override {
        runtimeInputs = [
          pkgs.shfmt
          pkgs.prettier
        ];
        settings.formatter = {
          shfmt = {
            command = "shfmt";
            options = [
              "--indent"
              "2"
              "--case-indent"
              "--write"
            ];
            includes = [
              "*.sh"
              "scripts/repo-clone"
            ];
          };
          prettier = {
            command = "prettier";
            options = [ "--write" ];
            includes = [ "*.md" ];
          };
        };
      };

      # `nix flake check`. darwinConfigurations is not a standard flake output,
      # so stock nix walks straight past it and checks nothing; naming each
      # host's toplevel here makes the check real on any nix.
      checks.${system} = lib.mapAttrs' (
        name: cfg: lib.nameValuePair "darwin-${name}" cfg.config.system.build.toplevel
      ) self.darwinConfigurations;
    };
}
