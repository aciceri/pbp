{ config, pkgs, ... }:
{
  services = {
    openssh = {
      enable = true;
      permitRootLogin = "yes";
    };

    # Enable CUPS to print documents.
    printing = {
      enable = true;
    };

    redshift = {
      enable = true;
      temperature = {
        day = 6500;
        night = 3700;
      };
      package = pkgs.redshift-wlr;
    };

    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="acpi_video0", GROUP="video", MODE="0664" #for the backlight setting as user in video group
    '';

  };
}

