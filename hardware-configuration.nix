{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "usbhid" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/5aa67d2d-93fd-4e7c-b634-aa8d7b65bbb8";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/C406-2AFC";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/e236d328-496e-4cf8-ba54-857789ca258f"; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
