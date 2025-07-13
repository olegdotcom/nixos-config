{
  description = "NixOS system for oleg-laptop";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      ghostty,
      ...
    }:
    {
      nixosConfigurations.oleg-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.framework-amd-ai-300-series
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.oleg = import ./home.nix;
            home-manager.extraSpecialArgs = { inherit ghostty; };
          }
        ];
      };
    };
}
