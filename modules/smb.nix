{username, ...}: {
  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  networking.firewall = {
    allowedTCPPorts = [139 445];
    allowedUDPPorts = [137 138];
  };
  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    shares = {
      Share = {
        path = "/home/${username}/Share";
        browseable = "no";
        "read only" = "no";
        "guest ok" = "no";
        "force user" = "${username}";
        "force group" = "users";
      };
    };
  };
}
