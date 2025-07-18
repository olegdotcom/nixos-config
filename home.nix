{
  config,
  pkgs,
  ghostty,
  ...
}:

let
  power-profile-script = pkgs.writeShellScriptBin "power-profile-switch" ''
    #!${pkgs.runtimeShell}

    # Get the current profile and set the corresponding icon
    get_profile() {
        PROFILE=$(${pkgs.power-profiles-daemon}/bin/powerprofilesctl get)
        case "$PROFILE" in
            performance)
                ICON="🚀"
                ;;
            balanced)
                ICON="⚖️"
                ;;
            power-saver)
                ICON="🌿"
                ;;
            *)
                ICON="?"
                ;;
        esac
    }

    # Handle the click event to switch profiles
    case "$1" in
        switch)
            CURRENT_PROFILE=$(${pkgs.power-profiles-daemon}/bin/powerprofilesctl get)
            case "$CURRENT_PROFILE" in
                performance)
                    ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver
                    ;;
                balanced)
                    ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance
                    ;;
                power-saver)
                    ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced
                    ;;
            esac
            ;;
    esac

    # Get the current state and output JSON for Waybar
    get_profile
    printf '{"text": "%s", "tooltip": "Power Profile: %s", "class": "%s"}\n' "$ICON" "$PROFILE" "$PROFILE"
  '';
in
{
  home.username = "oleg";
  home.homeDirectory = "/home/oleg";

  home.packages = with pkgs; [
    # Core
    neofetch
    ripgrep
    jq
    fzf
    which
    gh
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
    hyprland
    hyprlock
    hypridle
    foot
    ghostty.packages.${pkgs.system}.default
    anyrun
    waybar
    hyprpaper
    pavucontrol # Volume control for waybar
    pulseaudio
    networkmanagerapplet
    dconf
    hyprshot

    # Development
    gemini-cli
    nil
    nixpkgs-fmt
    lua-language-server
    gopls
    llvmPackages.clang

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

    # Custom scripts
    power-profile-script
  ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  programs.chromium = {
    enable = true;
    extensions = [
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # DarkReader
    ];
  };

  programs.git = {
    enable = true;
    userName = "Oleg Morfiianets";
    userEmail = "1759220+olegdotcom@users.noreply.github.com";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  # Set the system-wide color scheme preference to dark.
  # This is the modern way to signal dark mode to apps like Chromium.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      "color-scheme" = "prefer-dark";
    };
  };

  # Declaratively manage config files
  xdg.configFile = {
    "nvim".source = ./dotfiles/nvim;
    "hypr".source = ./dotfiles/hypr;
    "anyrun".source = ./dotfiles/anyrun;
    "bat".source = ./dotfiles/bat;
    "foot".source = ./dotfiles/foot;
    "ghostty".source = ./dotfiles/ghostty;
    "waybar".source = ./dotfiles/waybar;
    "yazi".source = ./dotfiles/yazi;
    "neofetch".source = ./dotfiles/neofetch;
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
