{
  description = "NixOS for Raspberry Pi 5";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
  };

  outputs = { self, nixpkgs, raspberry-pi-nix }:
    let
      inherit (nixpkgs.lib) nixosSystem;
      basic-config = { pkgs, lib, ... }: {
        # bcm2711 for rpi 3, 3+, 4, zero 2 w
        # bcm2712 for rpi 5
        # See the docs at:
        # https://www.raspberrypi.com/documentation/computers/linux_kernel.html#native-build-configuration
        raspberry-pi-nix.board = "bcm2711";
        time.timeZone = "Asia/Tashkent";
        users.users.root.initialPassword = "root";
        networking = {
          hostName = "basic-example";
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

    in {
      nixosConfigurations = {
        rpi-example = nixosSystem {
          # stateVersion = "24.05";
          system = "aarch64-linux";
          modules = [ raspberry-pi-nix.nixosModules.raspberry-pi basic-config ];
        };
      };
    };
  }
