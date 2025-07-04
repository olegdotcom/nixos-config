# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Enable firmware updates for hardware.
  hardware.enableRedistributableFirmware = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Firmware updater.
  services.fwupd.enable = true;

  # For power management on laptops.
  services.tlp.enable = true;

  networking.hostName = "oleg-laptop";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Set keyboard layout and map Caps Lock to Escape system-wide.
  # This is respected by both the console and Wayland/X11.
  console.useXkbConfig = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "caps:escape";

  # Enable sound.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth.enable = true;

  hardware.graphics = {
  	enable = true;
  };
  services.xserver.videoDrivers = [ "amdgpu" ];

  programs.hyprland = {
  	enable = true;
	xwayland.enable = true;
  };

  fonts.packages = with pkgs; [
  	noto-fonts
	noto-fonts-cjk-sans
	noto-fonts-emoji
  nerd-fonts.sauce-code-pro
  ];

  environment.sessionVariables = {
	  WLR_NO_HARDWARE_CURSORS = "1";
	  NIXOS_OZONE_WL = "1";
	  SDL_VIDEODRIVER = "wayland";
	  QT_QPA_PLATFORM = "wayland";
	  GDK_BACKEND = "wayland";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  users.users.oleg = {
    isNormalUser = true;
    home = "/home/oleg";
    extraGroups = [ "wheel" "networkmanager" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    neovim
    networkmanager
    wget
    git
    wayland
    xdg-desktop-portal-hyprland
  ];
  environment.variables.EDITOR = "nvim";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}
