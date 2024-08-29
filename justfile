build:
  nix build --system aarch64-darwin '.#nixosConfigurations.rpi-example.config.system.build.sdImage'
