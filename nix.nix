{
  inputs,
  lib,
  self,
  ...
}: {
  nix = {
    #automatically get registry from input flakes
    registry =
      (
        lib.attrsets.mapAttrs (
          _: value: {
            flake = value;
          }
        ) (
          lib.attrsets.filterAttrs (
            _: value: (
              !(lib.attrsets.hasAttrByPath ["flake"] value) || value.flake == false
            )
          )
          inputs
        )
      )
      // {system = {flake = self;};};
    #automatically add registry entries to nixPath
    nixPath = (lib.mapAttrsToList (name: value: name + "=" + value) inputs) ++ [("system=" + ./.)];
    settings = {
      experimental-features = ["nix-command" "flakes" "repl-flake"];
      auto-optimise-store = true;
      warn-dirty = false;
      flake-registry = builtins.toFile "empty-flake-registry.json" ''{"flakes":[],"version":2}'';
      keep-outputs = false;
      keep-derivations = false;
    };
  };
  environment.etc."booted-system".source = self;
}
