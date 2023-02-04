{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    nixpkgs-master.url = github:NixOS/nixpkgs;
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = github:the-argus/spicetify-nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    suckless = {
      url = github:ISnortPennies/suckless;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-config = {
      url = github:ISnortPennies/nvim-config;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sxhkd-flake = {
      url = github:ISnortPennies/sxhkd-flake;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fetch-rs = {
      url = github:ISnortPennies/fetch-rs;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        (final: prev: rec {
          t-rex-miner = final.callPackage ./pkgs/t-rex-miner {};
          afk-cmds = final.callPackage ./pkgs/afk-cmds {};
          parrot = final.callPackage ./pkgs/parrot {};
          webcord = inputs.nixpkgs-master.legacyPackages.${system}.webcord;
        })
        inputs.suckless.overlay
        inputs.fetch-rs.overlays.${system}.default
      ];
    };
  in {
    formatter.x86_64-linux = pkgs.alejandra;
    nixosConfigurations = {
      gerg-desktop = lib.nixosSystem {
        inherit system pkgs;
        specialArgs = {
          inherit inputs;
          settings = {
            username = "gerg";
            version = "23.05";
            hostname = "gerg-desktop";
          };
        };
        modules = [
          inputs.sxhkd-flake.nixosModules.sxhkd
          inputs.home-manager.nixosModules.home-manager
          ./home-manager
          ./configuration.nix
          ./systems/desktop.nix
          ./nix.nix
        ];
      };
      game-laptop = lib.nixosSystem {
        inherit system pkgs;
        specialArgs = {
          inherit inputs;
          settings = {
            username = "games";
            version = "23.05";
            hostname = "game-laptop";
          };
        };
        modules = [
          inputs.sxhkd-flake.nixosModules.sxhkd
          inputs.home-manager.nixosModules.home-manager
          ./home-manager
          ./configuration.nix
          ./systems/laptop.nix
          ./nix.nix
        ];
      };
    };
  };
}
