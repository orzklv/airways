{ pkgs, ... }: {
  config = {
    # Bootloader.
    boot = {
      loader = {
        raspberryPi = {
          enable = true;
          version = 4;
        };
      };
    };
  };
}
