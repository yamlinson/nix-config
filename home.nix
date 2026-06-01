{ config, pkgs, lib, ... }:

{
  home.username = "main";
  home.homeDirectory = "/home/main";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [

    # Shell tools
    # zsh
    # zsh-autocomplete
    # zsh-syntax-highlighting
    # zsh-powerlevel10k
    # zsh-vi-mode
    neovim
    zoxide
    # starship
    fzf
    unzip
    ripgrep
    fd
    bat
    eza
    tldr

    # Tmux
    tmux
    sesh

    # Development
    git
    lazygit
    gnumake
    cmake
    gh
    forgejo-cli
    mise
    gcc

    # Language tooling
    nodejs
    python3
    uv
    rustc
    cargo
    go
    ruby

    # Dot files
    chezmoi

    # Direnv for per-project environments
    nix-direnv
  ];

  # Git configuration
  programs.git.settings = {
    enable = true;
    user.name = "yamlinson";
    user.email = "95899054+yamlinson@users.noreply.github.com";
    init.defaultBranch = "main";
    push.autoSetupRemote = true;
  };

  # Shell configuration
  # programs.bash = {
  #   enable = true;
  #   initExtra = ''
  #     eval "$(starship init bash)"
  #     eval "$(direnv hook bash)"
  #   '';
  # };

  programs.zsh = {
    enable = true;
    dotDir = "/home/main/.config/zsh"; # .zshrc managed by Chezmoi
    plugins = with pkgs; [
      {
        name = "powerlevel10k";
        src = zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "zsh-autosuggestions";
        src = zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-vi-mode";
        src = zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.zsh";
      }
    ];
    initContent = ''
      # Source Chezmoi-managed configuration
      if [[ -f ~/.zshrc ]]; then
        source ~/.zshrc
      fi
    '';
  };

  home.sessionVariables.EDITOR = "nvim";
  home.shellAliases = { vi = "nvim"; vim = "nvim"; };

  # Place TPM in the correct location (read-only symlink to /nix/store)
  home.file."/home/main/.config/tmux/plugins/tpm" = {
    source = pkgs.fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tpm";
      rev = "v3.1.0";
      sha256 = "sha256-CeI9Wq6tHqV68woE11lIY4cLoNY8XWyXyMHTDmFKJKI=";
    };
    # Make the symlink recursive so TPM can see it's a directory
    recursive = true;
  };

  # Enable direnv integration
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Automatic chezmoi initialization and application
  home.activation.chezmoiInitAndApply = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
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
