{
  description = "NixOS system for oleg-laptop";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Hyprland 0.57.0 and portal 1.5.0, packaged in nixpkgs ahead of nixos-unstable.
    # TODO: Remove this input and the two package overrides below once our
    # nixos-unstable pin includes Hyprland 0.57 or newer.
    hyprland-nixpkgs.url = "github:NixOS/nixpkgs/2de5f15dcaa92e88bedf42ba49ffbf3ff04a76e4";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      # Use this flake's nixpkgs revision instead of downloading a second one.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      hyprland-nixpkgs,
      disko,
      nixos-hardware,
      home-manager,
      ...
    }:
    {
      nixosConfigurations.oleg-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.framework-amd-ai-300-series
          disko.nixosModules.disko
          ./disk-config.nix
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            programs.hyprland.package = hyprland-nixpkgs.legacyPackages.x86_64-linux.hyprland;
            programs.hyprland.portalPackage =
              hyprland-nixpkgs.legacyPackages.x86_64-linux.xdg-desktop-portal-hyprland;

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.oleg = import ./home.nix;
          }
        ];
      };

      # Make `nix fmt` recursively format every tracked Nix file.
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
