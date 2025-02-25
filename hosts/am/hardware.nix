# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/90e1092e-dff9-4b7f-82ea-9f28692ccb82";
    fsType = "btrfs";
    options = [
      "subvol=root"
      "compress=zstd"
      "noatime"
    ];
  };

  boot.initrd.luks.devices."enc".device = "/dev/disk/by-uuid/42b115e4-218e-47da-94d6-9425368de467";

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/90e1092e-dff9-4b7f-82ea-9f28692ccb82";
    fsType = "btrfs";
    options = [
      "subvol=home"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/90e1092e-dff9-4b7f-82ea-9f28692ccb82";
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/90e1092e-dff9-4b7f-82ea-9f28692ccb82";
    fsType = "btrfs";
    options = [
      "subvol=persist"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/90e1092e-dff9-4b7f-82ea-9f28692ccb82";
    fsType = "btrfs";
    options = [
      "subvol=log"
      "compress=zstd"
      "noatime"
    ];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/EC1F-1BE3";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/e4a451be-bf1e-4328-91a1-015c1da951a2";
      randomEncryption.enable = true;
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0f1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
