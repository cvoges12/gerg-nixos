inputs: {
  pkgs,
  settings,
  self,
  config,
  ...
}: {
  imports = [
    (import ./vfio.nix inputs)
    (import ./parrot.nix inputs)
    (import ./spicetify.nix inputs)
    (import ./zfs.nix inputs)
    (import ./containers inputs)
    (import ./erase-your-darlings.nix inputs)
  ];

  disko.devices = import ./disko.nix;

  localModules = {
    X11Programs = {
      sxhkd.enable = true;
      picom.enable = true;
    };
    DE.dwm.enable = true;
    DM = {
      lightdm.enable = true;
      autoLogin = true;
    };
    theming = {
      enable = true;
      kmscon.enable = true;
    };
  };
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    nvidiaPersistenced = false;
    nvidiaSettings = false;
    modesetting.enable = true;
    open = true;
  };
  services.xserver = {
    videoDrivers = ["nvidia" "amdgpu"];
  };
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    pkgs.bitwarden #store stuff
    pkgs.qbittorrent #steal stuff
    pkgs.pavucontrol #gui volume control
    pkgs.pcmanfm #file manager
    pkgs.librewolf #best browser
    #pointless stuff
    pkgs.vlc #play stuff
    pkgs.neovide #gui neovim
    pkgs.ripgrep
    inputs.suckless.packages.${pkgs.system}.st
    pkgs.alacritty
    pkgs.lutris
    pkgs.prismlauncher
    # wrap webcord to remove state file https://github.com/SpacingBat3/WebCord/issues/360
    (pkgs.symlinkJoin {
      name = "webcord-wrapper";
      nativeBuildInputs = [pkgs.makeWrapper];
      paths = [
        pkgs.webcord
      ];
      postBuild = ''
        wrapProgram "$out/bin/webcord" --run 'rm $HOME/.config/WebCord/windowState.json'
      '';
    })
  ];

  environment.etc."xdg/alacritty/alacritty.yml".source = "${self}/misc/alacritty.yml";
  networking = {
    useDHCP = false;
    hostName = "gerg-desktop";
    hostId = "288b56db";
    nameservers = [
      "192.168.1.1"
      "2605:59c8:252e:500::1"
    ];
    defaultGateway = "192.168.1.1";
    interfaces = {
      "enp11s0" = {
        name = "eth0";
      };
      "bridge0" = {
        name = "bridge0";
        macAddress = "D8:5E:D3:E5:47:90";
        ipv4.addresses = [
          {
            address = "192.168.1.4";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = "2605:59c8:252e:500:da5e:d3ff:fee5:4790";
            prefixLength = 64;
          }
        ];
      };
    };
    bridges."bridge0".interfaces = ["eth0"];
    firewall.enable = true;
  };
  #user managment
  sops.secrets = {
    root.neededForUsers = true;
    gerg.neededForUsers = true;
  };
  users = {
    mutableUsers = false;
    users = {
      "${settings.username}" = {
        useDefaultShell = true;
        uid = 1000;
        isNormalUser = true;
        extraGroups = ["wheel" "audio"];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAuO/3IF+AjH8QjW4DAUV7mjlp2Mryd+1UnpAUofS2yA gerg@gerg-phone"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILpYY2uw0OH1Re+3BkYFlxn0O/D8ryqByJB/ljefooNc gerg@gerg-windows"
        ];
        passwordFile = config.sops.secrets.gerg.path;
      };
      "root" = {
        uid = 0;
        home = "/root";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAuO/3IF+AjH8QjW4DAUV7mjlp2Mryd+1UnpAUofS2yA gerg@gerg-phone"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILpYY2uw0OH1Re+3BkYFlxn0O/D8ryqByJB/ljefooNc gerg@gerg-windows"
        ];
        passwordFile = config.sops.secrets.root.path;
      };
    };
  };
  boot = {
    kernelModules = ["amdgpu"];
    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "sd_mod"];
      includeDefaultModules = false;
    };
  };

  system.stateVersion = "23.05";
}
