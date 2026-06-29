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

  # Enable redistributable firmware. The Framework hardware module also
  # supplies the AMD graphics/initrd setup and enables fwupd for this laptop.
  hardware.enableRedistributableFirmware = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  # Keep only twenty boot entries so old kernels do not fill the 510 MiB EFI partition.
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable the standard NixOS laptop power-management settings.
  powerManagement.enable = true;
  # Provide the D-Bus service used by Waybar to view and change power profiles.
  services.power-profiles-daemon.enable = true;

  # Track the newest kernel for current Framework hardware support.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "oleg-laptop";
  networking.networkmanager.enable = true;
  # Resolve the NAS without mDNS/Avahi, which avoids opening UDP 5353 globally.
  networking.hosts."192.168.10.12" = [ "nas.local" ];

  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Set keyboard layout system-wide.
  # This is respected by both the console and Wayland.
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

  programs.hyprland = {
    enable = true;
    # Explicitly disable the X compatibility server for a Wayland-only session.
    xwayland.enable = false;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.sauce-code-pro
  ];

  environment.sessionVariables = {
    # Ask Chromium/Electron applications to prefer their native Wayland backend.
    NIXOS_OZONE_WL = "1";
    # Ask SDL applications to render directly through Wayland.
    SDL_VIDEODRIVER = "wayland";
    # Require the native Wayland backend for Qt and GTK applications.
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
    enable = false;
    settings = {
      default_session = {
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet --cmd '${pkgs.hyprland}/bin/Hyprland'
        '';
        user = "greeter";
      };
    };
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
  # Desktop and user tools live in Home Manager below; only system-level tools
  # remain here. Neovim is system-wide so root can use it, and Tuigreet stays
  # installed while greetd is temporarily disabled.
  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    tuigreet
    nushell
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

    # The NAS has an explicit address, so no inbound ports or discovery
    # broadcasts are needed on public networks.
    openDefaultPorts = false;

    settings = {
      options = {
        # LAN-only hardening: use only the NAS's explicit address.
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
        # Do not broadcast this laptop through local Syncthing discovery.
        localAnnounceEnabled = false;
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

  # Run garbage collection weekly. It first removes profile generations older
  # than 30 days, then deletes store paths that are no longer referenced.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
