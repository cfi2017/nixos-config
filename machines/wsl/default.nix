{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.nixos-wsl.nixosModules.default ];

  wsl = {
    enable = true;
    defaultUser = config.cfi2017.user.name;
  };

  networking.hostName = "wsl";

  # WSL launches the default user directly and NixOS-WSL grants wheel
  # passwordless sudo. This host does not run sshd or need login secrets.
  sops = {
    age.generateKey = lib.mkForce false;
    secrets = lib.mkForce { };
  };
  users.allowNoPasswordLogin = true;

  home-manager.users.${config.cfi2017.user.name}.accounts.email.accounts.kabelsalat = {
    primary = true;
    notmuch.enable = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "26.05";

  cfi2017 = {
    stateVersion = "26.05";
    gpg.enable = true;
    persistence.enable = false;
    development-packages = {
      enable = true;
      tools = {
        c = false;
        go = false;
        rust = false;
        k8s = true;
        iac = true;
        python = false;
        networking = false;
        security = false;
        infra = true;
        cloud = true;
        dev = false;
      };
    };
  };
}
