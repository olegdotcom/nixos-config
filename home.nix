{
  config,
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
    hyprpaper
    hyprsunset
    foot
    ghostty
    anyrun
    waybar
    pavucontrol
    networkmanagerapplet
    hyprshot

    # Development
    chatgpt
    nil
    nixfmt
    # Parser compiler used by nvim-treesitter.
    tree-sitter
    lua-language-server
    gopls
    llvmPackages.clang
    live-server
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
  ];

  home.stateVersion = "26.11";

  programs.home-manager.enable = true;

  programs.chromium = {
    enable = true;
    package = pkgs.chromium.override { enableWideVine = true; };
    extensions = [
      { id = "dpjamkmjmigaoobjbekmfgabipmfilij"; } # Empty New Tab Page
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
      { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; } # uBlock Origin Lite
      { id = "khncfooichmfjbepaaaebmommgaepoid"; } # Unhook
    ];
  };

  programs.firefox = {
    enable = true;
    policies.ExtensionSettings = {
      "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
        installation_mode = "normal_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
      };
      "uBlock0@raymondhill.net" = {
        installation_mode = "normal_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
      };
      "myallychou@gmail.com" = {
        installation_mode = "normal_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-recommended-videos/latest.xpi";
      };
    };
  };

  programs.git = {
    enable = true;
    settings = {
      core.editor = "nvim";
      user = {
        name = "Oleg Morfiyanets";
        email = "hi@oleg.com";
        signingKey = "${config.home.homeDirectory}/.ssh/id_ed25519_sk_yk1";
      };
      gpg = {
        format = "ssh";
        ssh.allowedSignersFile = "${config.xdg.configHome}/git/allowed_signers";
      };
      commit.gpgSign = true;
    };
  };

  # Public keys for all three YubiKeys; private key handles stay in ~/.ssh.
  xdg.configFile."git/allowed_signers".text = ''
    hi@oleg.com namespaces="git" sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIB+xvMQc0uz6Xu/IX6qFUf2JDCtjGrVuJo7cPK2YVtMOAAAABHNzaDo=
    hi@oleg.com namespaces="git" sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJ17zgK3Zadm/WF2fhoGAKIhy0YH2/DGH8VRiGjkvz+jAAAABHNzaDo=
    hi@oleg.com namespaces="git" sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIB1VDE+L+l7JoT8SeTPC59khM9C2/YNoRPDP70c+3yydAAAABHNzaDo=
  '';

  programs.jujutsu = {
    enable = true;
    settings = {
      ui.editor = "nvim";
      user = {
        inherit (config.programs.git.settings.user) name email;
      };
      signing = {
        backend = "ssh";
        key = config.programs.git.settings.user.signingKey;
        behavior = "drop";
        backends.ssh.allowed-signers = config.programs.git.settings.gpg.ssh.allowedSignersFile;
      };
      # Defer YubiKey interaction until push instead of signing every rewrite.
      git.sign-on-push = true;
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
      # Starship 1.27.0's default layout, with its VCS modules replaced by $vcs.
      format = builtins.concatStringsSep "" [
        "$username$hostname$localip$shlvl$singularity$kubernetes$nats"
        "$directory$vcsh$vcs"
        "$docker_context$package$bun$c$cmake$cobol$cpp$daml$dart$deno$dotnet"
        "$elixir$elm$erlang$fennel$fortran$gleam$golang$gradle$haskell$haxe$helm"
        "$java$julia$kotlin$lua$maven$mojo$nim$nodejs$ocaml$odin$opa$perl$php"
        "$pulumi$purescript$python$quarto$raku$rlang$red$ruby$rust$scala$solidity"
        "$swift$terraform$typst$vlang$vagrant$xmake$zig$buf$guix_shell$nix_shell"
        "$conda$pixi$meson$spack$memory_usage$aws$gcloud$openstack$azure$direnv"
        "$env_var$mise$crystal$custom$sudo$cmd_duration$line_break$jobs$battery"
        "$time$status$container$netns$os$shell$character"
      ];
      vcs.order = [
        "jj"
        "git"
      ];
      directory = {
        truncation_length = 0;
        truncate_to_repo = false;
      };
    };
  };

  # Rebuild the bat cache after theme changes.
  home.activation.rebuildBatCache = ''
    ${pkgs.bat}/bin/bat cache --build
  '';
}
