{
  pkgs,
  ...
}:

{
  home.username = "oleg";
  home.homeDirectory = "/home/oleg";

  home.packages = with pkgs; [
    # Core
    fastfetch
    ripgrep
    jq
    fzf
    which
    libva-utils # VA-API diagnostics.
    procps
    usbutils
    bat
    yazi
    fd
    tldr
    atuin
    zoxide

    # Hyprland ecosystem
    # Hyprland itself is installed by programs.hyprland in configuration.nix.
    hyprlock
    hypridle
    foot
    anyrun
    waybar
    hyprpaper
    pavucontrol
    networkmanagerapplet
    hyprshot

    # Development
    codex
    nil
    nixfmt
    # Parser compiler used by nvim-treesitter.
    tree-sitter
    lua-language-server
    gopls
    llvmPackages.clang
    # Debug adapters used by the Neovim DAP configuration.
    delve
    nodejs
    vscode-js-debug
    # nvim-dap-python locates debugpy through this interpreter.
    (python3.withPackages (pythonPackages: [ pythonPackages.debugpy ]))

    # Messaging
    signal-desktop

    # Archives
    zip
    xz
    unzip
    p7zip

    # Note-taking
    xournalpp

    # Media
    imv
    mpv

    # System monitoring
    bottom
    lm_sensors
    pamixer
    brightnessctl
    bolt
    bluetui

    ungoogled-chromium
  ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Oleg Morfiyanets";
        email = "1759220+olegdotcom@users.noreply.github.com";
      };
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    # Disable unused legacy language providers.
    withPython3 = false;
    withRuby = false;
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  # Prefer light themes in applications that respect the GNOME setting.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      "color-scheme" = "prefer-light";
    };
  };

  # Deploy native application configs through Home Manager.
  xdg.configFile = {
    "nvim".source = ./dotfiles/nvim;
    "hypr".source = ./dotfiles/hypr;
    "anyrun".source = ./dotfiles/anyrun;
    "bat".source = ./dotfiles/bat;
    "foot".source = ./dotfiles/foot;
    "waybar".source = ./dotfiles/waybar;
    "yazi".source = ./dotfiles/yazi;
  };

  programs.nushell = {
    enable = true;
    settings = {
      show_banner = false;
      edit_mode = "vi";
      ls.use_ls_colors = false;
    };
  };

  programs.atuin = {
    enable = true;
    settings = {
      keymap_mode = "vim-insert";
    };
  };

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = {
      directory = {
        truncation_length = 0;
      };
    };
  };

  # Rebuild the bat cache after theme changes.
  home.activation.rebuildBatCache = ''
    ${pkgs.bat}/bin/bat cache --build
  '';
}
