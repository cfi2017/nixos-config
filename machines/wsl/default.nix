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
    # Must match the user the shared modules configure (home-manager, sops, groups).
    defaultUser = config.cfi2017.user.name;
  };

  networking.hostName = "wsl";

  # No sshd here, so there is no host key to derive an age identity from.
  # sops decrypts with the age key at sops.age.keyFile instead; its public key
  # must be a recipient in .sops.yaml.
  sops.age.sshKeyPaths = lib.mkForce [ ];

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
