# Compile kernel with specific module for specific
# Raspberry Pi versions.
#
#
{ pkgs
, lib
, config
, ...
}:
let
  if_let = v: p: if lib.attrsets.matchAttrs p v then v else null;

  match = v: l: builtins.elemAt
    (
      lib.lists.findFirst
        (
          x: (if_let v (builtins.elemAt x 0)) != null
        )
        null
        l
    ) 1;

  # Kernel compilation for image + instance
  # > bcm2711 for rpi 3, 3+, 4, zero 2 w
  # > bcm2712 for rpi 5
  # See the docs at: https://www.raspberrypi.com/documentation/computers/linux_kernel.html#native-build-configuration
  module = match config.ranix [
    [{ board = "zero 2 w"; } "bcm2711"]
    [{ board = "3"; } "bcm2711"]
    [{ board = "3+"; } "bcm2711"]
    [{ board = "4"; } "bcm2711"]
    [{ board = "5"; } "bcm2712"]
  ];

  cfg = lib.mkIf config.ranix.enable
    {
      raspberry-pi-nix.board = module;
    };
in
{
  options = {
    ranix = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable networking configs.";
      };

      board = lib.mkOption {
        type = lib.types.str;
        default = "5";
        description = "The model of Raspberry Pi";
      };
    };
  };

  config = lib.mkMerge [ cfg ];
};
