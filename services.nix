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
  };
}

