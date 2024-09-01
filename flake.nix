{
  description = "NixOS for Raspberry Pi 5";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    # Flake utils for eachSystem
    flake-utils.url = "github:numtide/flake-utils";

    # Raspberry Pi Nix modules for creating images
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
  };

  outputs =
    { self
    , nixpkgs
    , raspberry-pi-nix
    , ...
    } @ inputs:
    let
      inherit (self) outputs;

      # Legacy packages are needed for home-manager
      lib = nixpkgs.lib; # // home-manager.lib

      # Supported systems for your flake packages, shell, etc.
      systems = [
        # For compilations
        "aarch64-linux"
        "x86_64-linux"

        # Development only
        "aarch64-darwin"
      ];


      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Define a development shell for each system
      devShellFor = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        pkgs.mkShell {
          NIX_CONFIG = "extra-experimental-features = nix-command flakes";
          buildInputs = with pkgs; [
            nix
            nil
            git
            nixd
            just
            nixpkgs-fmt
            nixpkgs-lint
          ];

          # Set environment variables, if needed
          shellHook = ''
            # export SOME_VAR=some_value
            echo "Welcome to Sokhibjon's dotfiles!"
          '';
        };


      general-config = { pkgs, lib, ... }: {
        # bcm2711 for rpi 3, 3+, 4, zero 2 w
        # bcm2712 for rpi 5
        # See the docs at:
        # https://www.raspberrypi.com/documentation/computers/linux_kernel.html#native-build-configuration
        raspberry-pi-nix.board = "bcm2711";
        time.timeZone = "Asia/Tashkent";
        users.users.root.initialPassword = "root";
        networking = {
          hostName = "SR71";
          useDHCP = false;
          interfaces = {
            wlan0.useDHCP = true;
            eth0.useDHCP = true;
          };
        };
        hardware = {
          bluetooth.enable = true;
          raspberry-pi = {
            config = {
              all = {
                base-dt-params = {
                  # enable autoprobing of bluetooth driver
                  # https://github.com/raspberrypi/linux/blob/c8c99191e1419062ac8b668956d19e788865912a/arch/arm/boot/dts/overlays/README#L222-L224
                  krnbt = {
                    enable = true;
                    value = "on";
                  };
                };
              };
            };
          };
        };
      };

    in
    {
      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      formatter =
        forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      # Development shells
      devShell = lib.mapAttrs (system: _: devShellFor system) (lib.genAttrs systems { });

      nixosConfigurations = {
        SR71 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [ raspberry-pi-nix.nixosModules.raspberry-pi general-config ];
        };
      };
    };
}
