build:
  nix build '.#nixosConfigurations.Raided.config.system.build.sdImage'

build-emu:
  nix build --system x86_64-linux '.#nixosConfigurations.Raided.config.system.build.sdImage'
