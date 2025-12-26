{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Enable firmware updates for hardware.
  hardware.enableRedistributableFirmware = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  powerManagement.enable = true;
  boot.kernelParams = [
    # Slow sleep to save battery
    "mem_sleep_default=deep"
  ];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Explicitly load amdgpu driver for VRR and Wayland.
  boot.kernelModules = [ "amdgpu" ];
  boot.initrd.availableKernelModules = [ "amdgpu" ];

  # Firmware updater.
  services.fwupd.enable = true;

  networking.hostName = "oleg-laptop";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Set keyboard layout system-wide.
  # This is respected by both the console and Wayland/X11.
  console.useXkbConfig = true;
  services.xserver.xkb.layout = "us";

  # Enable sound.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.hardware.bolt.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  hardware.graphics = {
    enable = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = false;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.sauce-code-pro
  ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
  };

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Enable greetd, a minimal and flexible login manager, with the wlgreet greeter.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet --cmd '${pkgs.hyprland}/bin/Hyprland'
        '';
        user = "greeter";
      };
    };
  };

  # Enable Avahi for mDNS, allowing .local domain resolution for the NAS.
  services.avahi = {
    enable = true;
    nssmdns4 = true; # For IPv4
    nssmdns6 = true; # For IPv6
  };

  users.users.oleg = {
    isNormalUser = true;
    home = "/home/oleg";
    uid = 1000;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    shell = pkgs.nushell;
  };
  users.groups.users.gid = 100;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    neovim
    networkmanager
    wget
    git
    wayland
    xdg-desktop-portal-hyprland
    tuigreet
    nushell
    hyprlock
    cifs-utils
  ];

  fileSystems =
    let
      # Mounting options.
      cifsOptions = [
        "credentials=/etc/nixos/smb-credentials"
        "uid=${toString config.users.users.oleg.uid}"
        "gid=${toString config.users.groups.users.gid}"
        "user"
        "users"
        "x-systemd.automount"
        "x-systemd.idle-timeout=1min"
        "x-systemd.mount-timeout=10s"
        "noauto"
      ];
      # Function to generate a mount point configuration.
      mkCifsMount = share: {
        device = "//nas.local/${share}";
        fsType = "cifs";
        options = cifsOptions;
      };
    in
    {
      "/mnt/nas/core" = mkCifsMount "core";
      "/mnt/nas/dump" = mkCifsMount "dump";
      "/mnt/nas/photos" = mkCifsMount "photos";
    };

  services.syncthing = {
    enable = true;
    user = "oleg";
    dataDir = "/home/oleg";
    configDir = "/home/oleg/.config/syncthing";

    openDefaultPorts = true;

    settings = {
      options = {
        # LAN-only hardening
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
        localAnnounceEnabled = true;
        urAccepted = -1; # disable usage reporting
      };

      devices = {
        nas = {
          id = "QLSLGHB-4AC64CH-RISJDID-ZINNZ5T-5PPP4FD-ZYJCOFP-LLGVYLB-APRXXQX";
          addresses = [
            "tcp://192.168.10.12:22000"
          ];
        };
      };

      folders = {
        core = {
          path = "/home/oleg/core";
          devices = [ "nas" ];
          type = "sendreceive";

          # Important settings
          ignorePerms = true;
          fsWatcherEnabled = true;
        };
      };
    };
  };

  # First NixOS version installed on this machine.
  system.stateVersion = "25.05";

  # Automatically run garbage collection daily to clean the Nix store.
  nix.gc = {
    automatic = true;
    dates = "daily";
  };

  # Automatically delete all but the last 10 generations daily.
  systemd.services.cleanup-generations = {
    description = "Clean up old NixOS generations";
    script = ''
      ${pkgs.nix}/bin/nix-env -p /nix/var/nix/profiles/system --delete-generations +10
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.timers.cleanup-generations = {
    description = "Daily timer for cleaning up old NixOS generations";
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };
}
