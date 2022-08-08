{
  description = "my personal configurations";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixkpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        packageOverrides = super: let self = super.pkgs; in {
          #more overrides can go here
          polkit_fix = self.polkit_gnome.overrideAttrs ( oldAttrs: rec 
          {
            postInstall = ''
             mkdir $out/bin
             ln -s $out/libexec/polkit-gnome-authentication-agent-1 $out/bin/polkit-gnome-authentication-agent-1
            '';
          });
          nerdfonts-overpass = self.nerdfonts.override {
            fonts = [ "Overpass" ];
          };
        };
      };
    };
    lib = nixpkgs.lib;
  in {
    homeManagerConfiguration = {
      gerg = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home-manager/home-manager.nix
        ];
      };
    };
    nixosConfigurations = {
      gerg-laptop = lib.nixosSystem { 
        inherit system pkgs;
        modules = [
          ./hardware-configuration.nix
          ./systems/laptop.nix
        ];
      };
      gerg-desktop = lib.nixosSystem { 
        inherit system pkgs;
        modules = [
          ./hardware-configuration.nix
          ./systems/desktop.nix
        ];
      };
    };
  };
}
