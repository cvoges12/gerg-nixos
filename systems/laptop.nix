{
  pkgs,
  settings,
  lib,
  ...
}: {
  imports = let
    modules = [
      "boot"
      "fonts"
      "git"
      "packages"
      "picom"
      "prime"
      "scripts"
      "sxhkd"
      "xserver"
      "shells"
      "gaming"
    ];
  in
    lib.lists.forEach modules (
      m:
        ../modules + ("/" + m + ".nix")
    );
  networking.hostName = settings.hostname;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.cpu.amd.updateMicrocode = true;
  users = {
    defaultUserShell = pkgs.zsh;
    users."${settings.username}" = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = ["audio" "networkmanager"];
    };
  };
  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = settings.username;
  };
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  boot = {
    initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci"];
    kernelModules = ["kvm-amd"];
  };
  fileSystems = {
    "/" = {
      device = "/dev/nvme0n1p2";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/nvme0n1p1";
      fsType = "vfat";
    };
  };
}
