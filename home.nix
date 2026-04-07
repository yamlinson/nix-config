{ config, pkgs, ... }:

{
  home.username = "main";
  home.homeDirectory = "/home/main";
  home.stateVersion = "25.11";

  # Packages for interactive use
  home.packages = with pkgs; [
    # Editor
    neovim

    # Shell tools
    zsh
    zsh-autocomplete
    zsh-syntax-highlighting
    zsh-powerlevel10k
    zsh-vi-mode
    zoxide
    # starship
    fzf
    ripgrep
    fd
    bat
    eza

    # Tmux
    tmux
    sesh

    # Development
    git
    lazygit
    gh

    # Language tooling
    nodejs
    python3
    rustc
    cargo
    go

    # Dot files
    chezmoi

    # Direnv for per-project environments
    nix-direnv
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "yamlinson";
    userEmail = "95899054+yamlinson@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  # Shell configuration
  # programs.bash = {
  #   enable = true;
  #   initExtra = ''
  #     eval "$(starship init bash)"
  #     eval "$(direnv hook bash)"
  #   '';
  # };

  # Or zsh:
  programs.zsh.enable = true;
  # programs.zsh.initExtra = ''...'';

  # Neovim configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Place TPM in the correct location (read-only symlink to /nix/store)
  home.file.".tmux/plugins/tpm" = {
    source = pkgs.fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tpm";
      rev = "v3.1.0";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
    # Make the symlink recursive so TPM can see it's a directory
    recursive = true;
  };

  # Enable direnv integration
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Automatic chezmoi initialization and application
  home.activation.chezmoiInitAndApply = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Ensure we have access to home.packages in PATH
    export PATH="${lib.makeBinPath config.home.packages}:$PATH"

    # Initialize chezmoi if not already set up
    if [ ! -d "${config.home.homeDirectory}/.local/share/chezmoi" ]; then
      echo "Initializing chezmoi..."
      $DRY_RUN_CMD chezmoi init --apply https://github.com/yamlinson/dotfiles.git
    else
      # Already initialized, just apply any updates
      echo "Applying chezmoi changes..."
      $DRY_RUN_CMD chezmoi apply
    fi
  '';
}
