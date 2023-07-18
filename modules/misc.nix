_: {
  lib,
  config,
  pkgs,
  ...
}: {
  options.local.allowedUnfree = lib.mkOption {
    type = lib.types.listOf lib.types.string;
    default = [];
  };

  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.local.allowedUnfree;

    environment.defaultPackages = lib.mkForce (builtins.attrValues {
      inherit
        (pkgs)
        alsa-utils #volume control
        bottom #view tasks
        efibootmgr #efi editor
        nix-output-monitor #nom nom nom nom;
        nix-tree #view packages
        pciutils #lspci
        xclip #commandline clipboard access
        ;
    });

    #enable ssh
    programs.mtr.enable = true; #ping and traceroute
    services.openssh = {
      enable = true;
      hostKeys = lib.mkForce [];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
    i18n.defaultLocale = "en_US.UTF-8";
    #time settings
    time.timeZone = "America/New_York";
  };
}
