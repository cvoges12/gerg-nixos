{
  inputs = {
    #nixpkgs refs
    master = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "master";
    };
    unstable = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };
    stable = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-23.05";
    };
    #nix itself
    nix = {
      type = "github";
      owner = "NixOS";
      repo = "nix";
      ref = "1a14ce83811038b05b653df461a944ef0847d14d";
      inputs.nixpkgs.follows = "unstable";
    };
    nixos-generators = {
      type = "github";
      owner = "nix-community";
      repo = "nixos-generators";
      inputs.nixpkgs.follows = "unstable";
    };
    sops-nix = {
      type = "github";
      owner = "mic92";
      repo = "sops-nix";
      inputs.nixpkgs.follows = "unstable";
    };
    disko = {
      type = "github";
      owner = "nix-community";
      repo = "disko";
      inputs.nixpkgs.follows = "unstable";
    };
    nixfmt = {
      type = "github";
      owner = "piegamesde";
      repo = "nixfmt";
      ref = "rfc101-style";
      inputs.nixpkgs.follows = "unstable";
    };
    #my own packages
    spicetify-nix = {
      type = "github";
      owner = "Gerg-L";
      repo = "spicetify-nix";
      inputs.nixpkgs.follows = "unstable";
    };
    suckless = {
      type = "github";
      owner = "Gerg-L";
      repo = "suckless";
      inputs.nixpkgs.follows = "unstable";
    };
    nvim-flake = {
      type = "github";
      owner = "Gerg-L";
      repo = "nvim-flake";
      inputs.nixpkgs.follows = "unstable";
    };
    fetch-rs = {
      type = "github";
      owner = "Gerg-L";
      repo = "fetch-rs";
      inputs.nixpkgs.follows = "unstable";
    };
  };

  outputs = x: import ./outputs.nix x;
}
