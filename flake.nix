{
  description = "NixOS for Raspberry Pi 5";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/home.nix'.

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake utils for eachSystem
    flake-utils.url = "github:numtide/flake-utils";

    # Raspberry Pi Nix modules for creating images
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";

    # TODO: Add any other flake you might need
    # hardware.url = "github:nixos/nixos-hardware";
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , flake-utils
    , raspberry-pi-nix
    , ...
    } @ inputs:
    let
      inherit (self) outputs;

      afes = flake-utils.lib.eachDefaultSystem
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          # Nixpkgs packages for the current system
          {
            # Your custom packages
            # Acessible through 'nix build', 'nix shell', etc
            packages = import ./pkgs { inherit pkgs; };

            # Formatter for your nix files, available through 'nix fmt'
            # Other options beside 'alejandra' include 'nixpkgs-fmt'
            formatter = pkgs.nixpkgs-fmt;

            # Development shells
            devShells.default = import ./shell.nix { inherit pkgs; };
          }
        );

      afse = {
        # Nixpkgs and Home-Manager helpful functions
        lib = nixpkgs.lib // home-manager.lib;

        # Your custom packages and modifications, exported as overlays
        overlays = import ./overlays { inherit inputs; };

        # Reusable nixos modules you might want to export
        # These are usually stuff you would upstream into nixpkgs
        nixosModules = import ./modules/nixos;

        # Reusable raspberry modules you might want to export
        # These are usually stuff you would upstream to support rpis
        ranixModules = import ./modules/ranix;

        # Reusable home-manager modules you might want to export
        # These are usually stuff you would upstream into home-manager
        homeManagerModules = import ./modules/home;

        # NixOS configuration entrypoint
        # Available through 'nixos-rebuild --flake .#your-hostname'
        nixosConfigurations = {
          Raided = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs outputs; };
            modules = [
              # > For SD Card image generation <
              raspberry-pi-nix.nixosModules.raspberry-pi

              # > Our main nixos configuration file <
              ./nixos/raided/configuration.nix
            ];
          };
        };
      };
    in
    afes // afse;
}
