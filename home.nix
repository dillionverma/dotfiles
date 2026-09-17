# User-level configuration (home-manager, wired in via darwin.nix).
# hostName comes from the flake attr name and me from me.nix (via extraSpecialArgs).
{ pkgs, config, hostName, me, ... }:

let
  # Canonical checkout of this repo. mkOutOfStoreSymlink and the drs alias
  # depend on this path — update it if the repo ever moves.
  dotfilesDir = "${config.home.homeDirectory}/src/personal/dotfiles";
in
{
  home.username = me.username;
  home.homeDirectory = "/Users/${me.username}";
  home.stateVersion = "25.05";

  ## Packages ----------------------------------------------------------------
  # Tools with a programs.* module below (git, gh, vim, tmux, bat, fzf,
  # zoxide, direnv, oh-my-posh) are installed by their module instead.
  home.packages = with pkgs; [
    # shell & file tools
    dust
    eza
    fd
    ffmpeg
    jq
    ripgrep
    wget
    yt-dlp

    # dev toolchain
    bitwarden-cli
    cloudflared
    devenv
    infisical
    pulumi-bin
    python3
    shellcheck
    uv

    # javascript: global baseline for one-off scripts; projects pin their own
    # versions via devenv/devshells (see templates/devenv)
    bun
    nodejs_24
    pnpm
    typescript
    typescript-language-server
    prettier

    # python tooling (replaces `uv tool install`)
    basedpyright
    ruff

    # rust: rustup keeps its normal toolchain UX (~/.rustup); bootstrap.sh
    # sets `rustup default stable` if no toolchain is configured
    rustup

    # repo management helper on PATH (replaces the DOTFILES_DIR sourcing trick)
    (pkgs.writeShellScriptBin "repo-clone" (builtins.readFile ./scripts/repo-clone))
  ];

  home.sessionVariables.PNPM_HOME = "${config.home.homeDirectory}/Library/pnpm";

  # home-manager PREPENDS these, so they win over the nix profiles. Keep them
  # free of anything nix also provides (no `uv tool install` / `cargo install`
  # of packages listed above) or the nix version gets shadowed. Homebrew is
  # last on purpose; never eval `brew shellenv` — it prepends.
  home.sessionPath = [
    "${config.home.homeDirectory}/Library/pnpm"
    "${config.home.homeDirectory}/.cargo/bin"
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.opencode/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  ## Zsh ---------------------------------------------------------------------
  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;

    # Cached compinit (port of the v1 .zshrc behavior).
    completionInit = ''
      autoload -Uz compinit
      autoload -Uz colors && colors
      zmodload zsh/complist
      mkdir -p "${config.xdg.cacheHome}/zsh"
      _zcompdump="${config.xdg.cacheHome}/zsh/.zcompdump-$ZSH_VERSION"
      if [[ -s "$_zcompdump" ]]; then
        compinit -C -d "$_zcompdump"
      else
        compinit -d "$_zcompdump"
      fi
    '';

    history = {
      path = "${config.xdg.stateHome}/zsh/history";
      size = 100000;
      save = 100000;
      extended = true;
      share = true;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      saveNoDups = true;
      findNoDups = true;
    };

    autosuggestion = {
      enable = true;
      strategy = [
        "history"
        "completion"
      ];
      highlight = "fg=8";
    };

    shellAliases = {
      ls = "eza --group-directories-first --icons=auto";
      ll = "eza -lah --group-directories-first --icons=auto";
      la = "eza -la --group-directories-first --icons=auto";
      lt = "eza --tree --level=2 --icons=auto";
      cat = ''bat --paging=never --style="numbers,changes,header"'';
      g = "git";
      ga = "git add";
      gb = "git branch";
      gc = "git commit";
      gd = "git diff";
      gl = "git pull --ff-only";
      gp = "git push";
      gpf = "git push --force-with-lease";
      gst = "git status -sb";
      gco = "git checkout";
      p = "pnpm";
      pd = "pnpm dev";
      pb = "pnpm build";
      reload = "source ~/.zshrc";
      drs = "sudo darwin-rebuild switch --flake ${dotfilesDir}#${hostName}";
    };

    initContent = ''
      setopt AUTO_PUSHD COMPLETE_IN_WORD HIST_REDUCE_BLANKS INTERACTIVE_COMMENTS
      setopt NO_BEEP PUSHD_IGNORE_DUPS PUSHD_SILENT PROMPT_SUBST

      # /etc/zshrc evals `brew shellenv`, which prepends /opt/homebrew. Undo it.
      path=( "''${(@)path:#/opt/homebrew/*}" /opt/homebrew/bin /opt/homebrew/sbin )

      # OrbStack CLI integration (docker/orb), if installed.
      source ~/.orbstack/shell/init.zsh 2>/dev/null || :

      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=* r:|=*'
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "${config.xdg.cacheHome}/zsh"
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

      bindkey -e
      stty -ixon 2>/dev/null
      bindkey '^[[H' beginning-of-line
      bindkey '^[[F' end-of-line
      # ^R is fzf's history widget (programs.fzf, sourced above); do not rebind.

      take() {
        mkdir -p "$1" && cd "$1"
      }

      rc() {
        local arg dir
        for arg in "$@"; do
          if [[ "$arg" == "--dry-run" ]]; then
            repo-clone "$@"
            return
          fi
        done
        dir="$(repo-clone "$@")" || return
        cd "$dir" || return
      }

      if command -v infisical >/dev/null 2>&1; then
        # Skip cleanly when this machine or shell has not been linked to an
        # Infisical project.
        infisical_npm_token_export="$(
          infisical export --env=dev --path=/ --format=dotenv --silent 2>/dev/null \
            | grep '^NPM_TOKEN_GOOGLE_SIGN_IN=' \
            | sed 's/^/export /'
        )"
        if [[ -n "$infisical_npm_token_export" ]]; then
          eval "$infisical_npm_token_export"
        fi
        unset infisical_npm_token_export
      fi

      if [[ -r "$HOME/.zshrc.local" ]]; then
        source "$HOME/.zshrc.local"
      fi

      # Syntax highlighting (Rust daemon; replaced fast-syntax-highlighting).
      # Upstream requires this after compinit and any bindkey calls, so keep
      # it the last line of initContent.
      eval "$(${pkgs.zsh-patina}/bin/zsh-patina activate)"
    '';
  };

  # Shell integrations wire their own zsh hooks — no hand-written evals.
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromJSON (builtins.readFile ./config/ohmyposh/vesper.omp.json);
  };

  ## Git ---------------------------------------------------------------------
  programs.git = {
    enable = true;

    # Replaces .config/git/ignore.
    ignores = [ "**/.claude/settings.local.json" ];

    settings = {
      user.name = me.fullName;
      user.email = me.email;
      merge.conflictstyle = "zdiff3";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      hyperlinks = true;
      keep-plus-minus-markers = false;
      side-by-side = false;
      syntax-theme = "Vesper"; # from programs.bat.themes below (shared cache)
      file-style = ''bold "#99ffe4"'';
      file-decoration-style = ''"#1c1c1c" ul'';
      hunk-header-style = ''file line-number bold "#b8a1ff"'';
      hunk-header-decoration-style = ''"#1c1c1c"'';
      hunk-header-file-style = ''"#99ffe4" bold'';
      hunk-header-line-number-style = ''"#ffc799"'';
      commit-style = ''"#ffc799" bold'';
      commit-decoration-style = ''"#1c1c1c"'';
      line-numbers-left-style = ''"#565f89"'';
      line-numbers-right-style = ''"#565f89"'';
      line-numbers-minus-style = ''"#ff8080"'';
      line-numbers-plus-style = ''"#99ffe4"'';
      line-numbers-zero-style = ''"#7d7d7d"'';
      minus-style = ''syntax "#201313"'';
      minus-emph-style = ''syntax "#3a1f1f"'';
      plus-style = ''syntax "#13211d"'';
      plus-emph-style = ''syntax "#1d332b"'';
      zero-style = ''syntax "#151515"'';
    };
  };

  # Replaces the hardcoded `/opt/homebrew/bin/gh` credential helper from the
  # v1 .gitconfig — that path dies the moment brew's gh is cleaned up.
  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
      hosts = [
        "https://github.com"
        "https://gist.github.com"
      ];
    };
  };

  # Replaces the v1 ~/.ssh/config marker block (upstream directive names).
  programs.ssh = {
    enable = true;
    # No implicit defaults; the "*" block below is the whole config.
    enableDefaultConfig = false;
    settings."*" = {
      AddKeysToAgent = "yes";
      IdentityFile = "~/.ssh/id_ed25519";
      UseKeychain = "yes";
    };
    # Resolved by Tailscale MagicDNS (no IP to keep in sync).
    settings."mac-mini" = {
      User = me.username;
      IdentityFile = "~/.ssh/id_ed25519";
      IdentitiesOnly = "yes";
    };
  };

  ## Vim ---------------------------------------------------------------------
  programs.vim = {
    enable = true;
    plugins = [ pkgs.vimPlugins.vim-gitgutter ];
    extraConfig = builtins.readFile ./config/vimrc;
  };
  home.file.".vim/colors/vesper.vim".source = ./config/vesper.vim;

  ## Terminal & app config files ---------------------------------------------
  programs.bat = {
    enable = true;
    # Installed to ~/.config/bat/themes and compiled by `bat cache --build` on
    # activation; delta reads the same cache for its syntax-theme.
    themes.Vesper = {
      src = ./config/bat;
      file = "Vesper.tmTheme";
    };
    config = {
      theme = "Vesper";
      style = "numbers,changes,header";
      pager = "less -FR";
    };
  };

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    mouse = true;
    historyLimit = 50000;
    baseIndex = 1;
    escapeTime = 0;
  };

  xdg.configFile."ghostty/config".source = ./config/ghostty/config;

  # zsh-patina syntax highlighting theme (daemon activated in initContent above).
  xdg.configFile."zsh-patina/config.toml".source = ./config/zsh-patina/config.toml;

  # Zed writes to its settings.json from the UI, so it must stay writable:
  # symlink to the repo checkout instead of the read-only nix store.
  xdg.configFile."zed/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/zed/settings.json";

  home.file.".superset/themes/vesper.json".source = ./config/superset/vesper.json;
}
