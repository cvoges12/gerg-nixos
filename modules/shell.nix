{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  environment = {
    systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        page
        exa
        direnv
        nix-direnv
        ;
      inherit
        (inputs.fetch-rs.packages.${pkgs.system})
        fetch-rs
        ;
    };
    binsh = lib.getExe pkgs.dash; #use dash for speed
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "page";
      SYSTEMD_PAGERSECURE = "true";
      DIRENV_LOG_FORMAT = "";
    };
    shellAliases = {
      #make sudo use aliases
      sudo = "sudo ";
      #paste link trick
      pastebin = "curl -F 'clbin=<-' https://clbin.com";
      #nix stuff
      gc-check = "nix-store --gc --print-roots | egrep -v \"^(/nix/var|/run/\w+-system|\{memory|/proc)\"";
      #vim stuff
      vi = "nvim";
      vim = "nvim";
      vimdiff = "nvim -d";
      #exa is 1 too many letters
      ls = "exa";
      l = "exa -lbF --git";
      ll = "exa -lbGF --git";
      llm = "exa -lbGd --git --sort=modified";
      la = "exa -lbhHigUmuSa --time-style=long-iso --git --color-scale";
      lx = "exa -lbhHigUmuSa@ --time-style=long-iso --git --color-scale";
      lS = "exa -1";
      lt = "exa --tree --level=2";
    };
    interactiveShellInit = "fetch-rs";
    pathsToLink = [
      "/share/nix-direnv"
    ];
  };
  security.sudo = {
    enable = true;
    execWheelOnly = true;
    extraConfig = ''
      Defaults env_keep += "${builtins.concatStringsSep " " (builtins.attrNames config.environment.variables)}"
      Defaults lecture = never
    '';
  };

  #zsh stuff
  users.defaultUserShell = pkgs.zsh;
  environment.shells = [pkgs.zsh];
  programs = {
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      histSize = 10000;
      histFile = "$HOME/.cache/zsh_history";
      shellInit = ''
        eval "$(direnv hook zsh)"
      '';
    };
    #starship
    starship = {
      enable = true;
      settings = {
        add_newline = false;
        format = "$sudo\${custom.direnv} $cmd_duration \n $directory$git_branch$character";
        character = {
          success_symbol = "[ ](#9ece6a bold)";
          error_symbol = "[ ](#db4b4b bold)";
        };
        directory = {
          read_only = " ";
        };
        git_branch = {
          style = "bold red";
        };
        sudo = {
          format = "[ ](#7aa2f7)";
          disabled = false;
        };
        cmd_duration = {
          min_time = 5000;
          style = "bold #9ece6a";
        };
        custom.direnv = {
          format = "[\\[direnv\\]]($style)";
          style = "#36c692";
          detect_folders = [".direnv"];
        };
      };
    };
  };
}
