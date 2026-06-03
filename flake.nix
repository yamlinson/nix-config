{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # System configuration
      nixosConfigurations.dev-server = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/dev-server/configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.main = import ./headless.nix;
            home-manager.users.code = import ./code.nix;
          }
        ];
      };
      nixosConfigurations.t2-macbook = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/t2-macbook/configuration.nix
          nixos-hardware.nixosModules.apple-t2
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.main = import ./hypr.nix;
            home-manager.users.code = import ./code.nix;
          }
        ];
      };
    };
}
