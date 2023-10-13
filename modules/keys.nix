_:
{ lib, ... }:
{
  options.local.keys = lib.mkOption { };

  config.local.keys = {
    gerg_gerg-phone = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDU6BnoHIgMLgZVGuvi03J9l5Z1yP1P5Q8QPyjRHyi77";
    gerg_gerg-windows = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILpYY2uw0OH1Re+3BkYFlxn0O/D8ryqByJB/ljefooNc";
    root_moms-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIq9YTf4jlVCKBKn44m4yJvj94C7pTOyaa4VjZFohNqD";
    root_game-desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJUKHZasYQUAmRBiqtx1drDxfq18/N4rKydCtPHx461I";
    root_gerg-desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIeHsGcmOdIMzV+SNe4WFcA3CPHCNb1aqxThkXtm7G/1";
    gerg-desktop_fingerprint = "BQxvBOWsTw1gdNDR0KzrSRmbVhDrJdG05vYXkVmw8yA";
    gerg_gerg-desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJWbwkFJmRBgyWyWU+w3ksZ+KuFw9uXJN3PwqqE7Z/i8";
  };
  _file = ./keys.nix;
}
