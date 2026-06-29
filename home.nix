{
  pkgs,
  ...
}:

{
  home.username = "oleg";
  home.homeDirectory = "/home/oleg";

  home.packages = with pkgs; [
    # Core
    # Fastfetch intentionally has no managed config, so it uses its defaults.
    fastfetch
    ripgrep
    jq
    fzf
    which
    libva-utils # For checking hardware video acceleration (vainfo)
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
    pavucontrol # Volume control for waybar
    # PipeWire supplies PulseAudio compatibility, so the PulseAudio server package is unnecessary.
    networkmanagerapplet
    hyprshot

    # Development
    codex
    nil
    # Official Nix formatter, used directly by editors and command-line tools.
    nixfmt
    # The Neovim 0.12-compatible nvim-treesitter branch uses the Tree-sitter
    # command-line tool to install and update language parsers. Keeping the
    # tool here makes it part of the reproducible Home Manager environment
    # instead of letting an editor plugin install an unmanaged executable.
    tree-sitter
    lua-language-server
    gopls
    llvmPackages.clang
    # Debug adapters used by the Neovim DAP configuration.
    delve
    nodejs
    vscode-js-debug
    # Include debugpy in the Python environment used by nvim-dap-python.
    (python3.withPackages (pythonPackages: [ pythonPackages.debugpy ]))

    # Messaging
    signal-desktop

    # archives
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

    # Browser
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
    # No installed plugins require Neovim's legacy Python or Ruby providers.
    # Setting these explicitly also prevents state-version migration warnings.
    withPython3 = false;
    withRuby = false;
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  # Set the system-wide color scheme preference to light.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      "color-scheme" = "prefer-light";
    };
  };

  # Declaratively manage config files
  # There is deliberately no Fastfetch/Neofetch entry: Fastfetch uses defaults.
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
    };
  };

  programs.atuin = {
    enable = true;
    settings = {
      keymap_mode = "vim-insert";
    };
    # Atuin's home-manager module automatically handles shell integration.
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

  # Rebuild bat cache after theme changes
  home.activation.rebuildBatCache = ''
    ${pkgs.bat}/bin/bat cache --build
  '';
}
