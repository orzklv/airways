{
  description = "NixOS for Raspberry Pi 5";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators, ... }:
  {
    nixosModules = {
      system = {
        disabledModules = [
          "profiles/base.nix"
        ];

        system.stateVersion = "24.05";
      };
      users = {
        users.users = {
          airline = {
            password = "UzbekistanAirways";
            isNormalUser = true;
            extraGroups = [ "wheel" ];
          };
        };
      };
    };

    packages.aarch64-linux = {
      sdcard = nixos-generators.nixosGenerate {
        system = "aarch64-linux";
        format = "sd-aarch64";
        modules = [
          ./extra.nix
          self.nixosModules.system
          self.nixosModules.users
        ];
      };
    };
  };
}
