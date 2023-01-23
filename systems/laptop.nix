{
  config,
  pkgs,
  callPackage,
  lib,
  username,
  ...
}: {
  #important stuff first
  imports = [
    ../modules/boot.nix
    ../modules/prime.nix
    ../modules/nvidia.nix
    ../modules/packages.nix
    ../modules/fonts.nix
    ../modules/scripts.nix
    ../modules/xserver.nix
    ../modules/zsh.nix
  ];
  networking.hostName = "gerg-laptop";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.cpu.amd.updateMicrocode = true;

  # end important stuff
  environment.systemPackages = with pkgs; [
    xorg.xf86videoamdgpu
  ];
  # user managment
  users = {
    defaultUserShell = pkgs.zsh;
    users."${username}" = {
      isNormalUser = true;
      extraGroups = ["wheel" "audio" "networkmanager"];
    };
  };
  boot = {
    initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci"];
    kernelModules = ["kvm-amd"];
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/c67796b3-d502-47db-8d0e-48f30bc91041";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/AD02-10EA";
      fsType = "vfat";
    };
  };
}
