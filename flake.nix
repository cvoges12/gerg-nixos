{
  inputs = {
    #channels
    master.url = "github:nixos/nixpkgs";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    stable.url = "github:nixos/nixpkgs/nixos-23.05";
    #nix 2.17
    nix.url = "github:nixos/nix/584ff408a4e2b6eb0d74989778c640a92089b6d4";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "unstable";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "unstable";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "unstable";
    };
    spicetify-nix = {
      #url = "github:the-argus/spicetify-nix";
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "unstable";
    };
    #my own packages
    suckless = {
      url = "github:gerg-L/suckless";
      inputs.nixpkgs.follows = "unstable";
    };
    nvim-flake = {
      url = "github:gerg-L/nvim-flake";
      inputs.nixpkgs.follows = "unstable";
    };
    fetch-rs = {
      url = "github:gerg-L/fetch-rs";
      inputs.nixpkgs.follows = "unstable";
    };
  };

  outputs = inputs: let
    lib = import ./lib inputs;
  in
    lib.gerg-utils {
      allowUnfree = true;
    } (
      {
        pkgs,
        system,
        ...
      }: {
        inherit lib;
        nixosConfigurations =
          lib.mkHosts
          "x86_64-linux"
          [
            "gerg-desktop"
            "game-laptop"
            "moms-laptop"
            "iso"
          ];

        nixosModules = lib.mkModules ./modules;

        diskoConfigurations =
          lib.mkDisko
          [
            "gerg-desktop"
            "game-laptop"
            "moms-laptop"
          ];
        formatter.${system} = pkgs.alejandra;

        devShells.${system}.default = pkgs.mkShell {
          packages = [
            pkgs.sops
          ];
        };

        packages.${system} = lib.mkPackages ./packages pkgs;
      }
    );
}
