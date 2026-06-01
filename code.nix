{ config, pkgs, lib, ... }:

{
  home.username = "code";
  home.homeDirectory = "/var/lib/code";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [

    # Shell tools
    fzf
    unzip
    ripgrep
    fd
    eza

    # Development
    git
    lazygit
    gnumake
    cmake
    mise
    gcc
    claude-code
    crush
    opencode

    # Language tooling
    nodejs
    python3
    uv
    rustc
    cargo
    go
    ruby

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
  programs.bash.enable = true;

  # Enable direnv integration
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
