project_name := "ranix"

default:
  @just --list

[doc('Buld from aarch64-linux NixOS')]
build:
  nix build '.#nixosConfigurations.Raided.config.system.build.sdImage'
  @just extract

[doc('Build from x86_64-linux NixOS')]
build-from-x86_64-linux:
  nix build --system x86_64-linux '.#nixosConfigurations.Raided.config.system.build.sdImage'
  @just extract

[doc('Clean all build artifacts')]
clean-all:
  rm -rf ./nixos-sd-image-*

[doc('Clean build artifacts except the image')]
clean-build:
  rm -rf ./result
  rm -rf ./nixos-sd-image-*.img.zst

[doc('Extract the image')]
extract:
  @just clean-all
  yes | cp -rf ./result/sd-image/nixos-sd-image-*.img.zst ./
  unzstd nixos-sd-image-*.img.zst
  @just clean-build
