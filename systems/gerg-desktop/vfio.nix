{
  pkgs,
  self,
  config,
  lib,
  inputs,
  ...
}:
###TAKEN FROM HERE:https://github.com/NixOS/nixpkgs/blob/4787ebf7ae2ab071389be7ff86cf38edeee7e9f8/nixos/modules/services/x11/xserver.nix#L106-L136
let
  xcfg = config.services.xserver;
  xserverbase = let
    fontsForXServer =
      config.fonts.fonts
      ++ [
        pkgs.xorg.fontadobe100dpi
        pkgs.xorg.fontadobe75dpi
      ];
  in
    pkgs.runCommand "xserverbase"
    {
      fontpath =
        lib.optionalString (xcfg.fontPath != null)
        ''FontPath "${xcfg.fontPath}"'';
      inherit (xcfg) config;
      preferLocalBuild = true;
    }
    ''
      echo 'Section "Files"' >> $out
      echo $fontpath >> $out
      for i in ${toString fontsForXServer}; do
        if test "''${i:0:''${#NIX_STORE}}" == "$NIX_STORE"; then
          for j in $(find $i -name fonts.dir); do
            echo "  FontPath \"$(dirname $j)\"" >> $out
          done
        fi
      done
      for i in $(find ${toString xcfg.modules} -type d); do
        if test $(echo $i/*.so* | wc -w) -ne 0; then
          echo "  ModulePath \"$i\"" >> $out
        fi
      done
      echo '${xcfg.filesSection}' >> $out
      echo 'EndSection' >> $out
      echo >> $out
    '';
  oneMonitor = pkgs.writeText "1-monitor.conf" (lib.strings.concatStrings [(builtins.readFile xserverbase) (builtins.readFile (self + /misc/1-monitor.conf))]);
  twoMonitor = pkgs.writeText "2-monitor.conf" (lib.strings.concatStrings [(builtins.readFile xserverbase) (builtins.readFile (self + /misc/2-monitor.conf))]);
in {
  ####VM SOUND BORKED
  services.pipewire.package = inputs.pipewire_fix.legacyPackages.${pkgs.system}.pipewire;
  boot = {
    kernelParams = ["amd_iommu=on" "iommu=pt" "vfio_iommu_type1.allow_unsafe_interrupts=1" "kvm.ignore_msrs=1"];
  };
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        #don't hook evdev at vm start
        package = pkgs.qemu.overrideAttrs (old: {
          patches =
            old.patches
            ++ [
              (pkgs.writeText "qemu.diff" ''
                diff --git a/ui/input-linux.c b/ui/input-linux.c
                index e572a2e..a9d76ba 100644
                --- a/ui/input-linux.c
                +++ b/ui/input-linux.c
                @@ -397,12 +397,6 @@ static void input_linux_complete(UserCreatable *uc, Error **errp)
                     }

                     qemu_set_fd_handler(il->fd, input_linux_event, NULL, il);
                -    if (il->keycount) {
                -        /* delay grab until all keys are released */
                -        il->grab_request = true;
                -    } else {
                -        input_linux_toggle_grab(il);
                -    }
                     QTAILQ_INSERT_TAIL(&inputs, il, next);
                     il->initialized = true;
                     return;
              '')
            ];
        });
        runAsRoot = true;
        ovmf.enable = true;
        verbatimConfig = ''
          user = "gerg"
          group = "kvm"
          namespaces = []
        '';
      };
    };
  };
  environment = {
    systemPackages = [
      pkgs.virt-manager
    ];
    shellAliases = {
      vm-start = "virsh start Windows";
      vm-stop = "virsh shutdown Windows";
    };
  };

  users.users.gerg.extraGroups = ["kvm" "libvirtd"];

  services.xserver.displayManager.xserverArgs = lib.mkAfter ["-config /tmp/xorg.conf"];
  services.xserver.displayManager.sessionCommands = lib.mkBefore ''
    if ! (test -e "/tmp/ONE_MONITOR"); then
          xrandr --output DP-0 --auto --mode 3440x1440 --rate 120 --primary --pos 0x0
          xrandr --output HDMI-A-1-0 --auto --mode 1920x1080 --rate 144 --set TearFree on --pos 3440x360
          xset -dpms
    fi
  '';

  systemd.tmpfiles.rules = let
    xml = pkgs.writeText "Windows.xml" (builtins.readFile (self + /misc/Windows.xml));
    qemuHook = pkgs.writeShellScript "qemu-hook" ''
      GUEST_NAME="$1"
      OPERATION="$2"
      SUB_OPERATION="$3"

      if [ "$GUEST_NAME" == "Windows" ]; then
        if [ "$OPERATION" == "prepare" ]; then
            systemctl stop display-manager.service
            modprobe -r -a nvidia_uvm nvidia_drm nvidia nvidia_modeset
            ${pkgs.libvirt}/bin/virsh nodedev-detach pci_0000_01_00_0
            ${pkgs.libvirt}/bin/virsh nodedev-detach pci_0000_01_00_1
            systemctl set-property --runtime -- user.slice AllowedCPUs=8-15,24-31
            systemctl set-property --runtime -- system.slice AllowedCPUs=8-15,24-31
            systemctl set-property --runtime -- init.scope AllowedCPUs=8-15,24-31
            ln -fs ${oneMonitor} /tmp/xorg.conf
            touch /tmp/ONE_MONITOR
            systemctl start display-manager.service
        fi
        if [ "$OPERATION" == "release" ]; then
          systemctl stop display-manager.service
          systemctl set-property --runtime -- user.slice AllowedCPUs=0-31
          systemctl set-property --runtime -- system.slice AllowedCPUs=0-31
          systemctl set-property --runtime -- init.scope AllowedCPUs=0-31
          ${pkgs.libvirt}/bin/virsh nodedev-reattach pci_0000_01_00_0
          ${pkgs.libvirt}/bin/virsh nodedev-reattach pci_0000_01_00_1
          modprobe -a nvidia_uvm nvidia_drm nvidia nvidia_modeset
          ln -fs ${twoMonitor} /tmp/xorg.conf
          rm /tmp/ONE_MONITOR
          systemctl start display-manager.service
        fi
      fi
    '';
  in [
    "L  /tmp/xorg.conf - - - - ${twoMonitor}"
    "L+ /var/lib/libvirt/hooks/qemu - - - - ${qemuHook}"
    "L+ /var/lib/libvirt/qemu/Windows.xml - - - - ${xml}"
  ];
}
