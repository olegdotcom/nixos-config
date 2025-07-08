{ config, pkgs, ... }:

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

    # Hyprland ecosystem
    hyprland
    hyprlock
    hypridle
    foot
    ghostty
    anyrun
    waybar
    hyprpaper
    pavucontrol # Volume control for waybar
    pulseaudio
    networkmanagerapplet
    dconf
    hyprshot

    # Development
    code-cursor-fhs
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
    extraConfig = {
      core.editor = "nvim";
    };
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
    "hypr/hyprland.conf".source = ./dotfiles/hypr/hyprland.conf;
    "hypr/hypridle.conf".source = ./dotfiles/hypr/hypridle.conf;
    "hypr/hyprpaper.conf".source = ./dotfiles/hypr/hyprpaper.conf;
    "hypr/wallpaper.png".source = ./dotfiles/hypr/wallpaper.png;
    "anyrun/config.ron".source = ./dotfiles/anyrun/config.ron;
    "anyrun/style.css".source = ./dotfiles/anyrun/style.css;
    "bat/config".source = ./dotfiles/bat/config;
    "bat/themes/catppuccin-mocha.tmTheme".source = ./dotfiles/bat/themes/catppuccin-mocha.tmTheme;
    "foot/foot.ini".source = ./dotfiles/foot/foot.ini;
    "ghostty/config".source = ./dotfiles/ghostty/config;
    "waybar/config".source = ./dotfiles/waybar/config;
    "waybar/style.css".source = ./dotfiles/waybar/style.css;
    "neofetch/config.conf".source = ./dotfiles/neofetch/config.conf;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.nushell = {
    enable = true;
  };

  # Rebuild bat cache after theme changes
  home.activation.rebuildBatCache = ''
    ${pkgs.bat}/bin/bat cache --build
  '';
}
