project_name := "ranix"

default:
  @just --list

[doc('Buld from aarch64-linux NixOS')]
build:
  nix build '.#nixosConfigurations.Raided.config.system.build.sdImage'

[doc('Build from x86_64-linux NixOS')]
build-from-x86_64-linux:
  nix build --system x86_64-linux '.#nixosConfigurations.Raided.config.system.build.sdImage'
