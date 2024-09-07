#
# Fan Control issues with Raspberry Pi
#
# If active cooling doesn't work or shuts off after 5 seconds
# this module should resolve the issue by adding system service
# that will check and track
{ pkgs, ... }: {
  config = {
    environment.systemPackages = with pkgs; [
      haskellPackages.gpio
      libraspberrypi
    ];

    # Service to control the fan
    systemd.services.fan-control = {
      description = "Control the fan depending on the temperature";
      script = ''
        /run/current-system/sw/bin/gpio init 18 out
        temperature=$(/run/current-system/sw/bin/vcgencmd measure_temp | grep -oE '[0-9]+([.][0-9]+)?')
        threshold=65
        if /run/current-system/sw/bin/awk -v temp="$temperature" -v threshold="$threshold" 'BEGIN { exit !(temp > threshold) }'; then
          /run/current-system/sw/bin/gpio write 18 hi
        else
          /run/current-system/sw/bin/gpio write 18 lo
        fi
        /run/current-system/sw/bin/gpio close 18 out
      '';
    };

    # Cron to trigger the main service
    systemd.timers.fan-control-timer = {
      description = "Run control fan script regularly";
      timerConfig = {
        OnCalendar = "*-*-* *:*:0/20"; # Run every 20 seconds
        Persistent = true;
        Unit = "fan-control.service";
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
