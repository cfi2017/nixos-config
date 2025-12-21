{
  config,
  lib,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf config.cfi2017.isLinux {
      cfi2017.core.zfs = lib.mkMerge [
        (lib.mkIf config.cfi2017.persistence.enable {
          homeDataLinks = [
            {
              directory = ".ssh";
              mode = "0700";
            }
          ];
          systemDataLinks = [
            {
              directory = "/root/.ssh/";
              mode = "0700";
            }
          ];
        })
      ];
    })
    {
      home-manager.users.${config.cfi2017.user.name} = lib.mkMerge [
        # Main SSH configuration (applies to all systems)
        {
          programs.ssh = {
            enable = true;
            enableDefaultConfig = false;
            matchBlocks = {
              "github" = {
                hostname = "github.com";
                user = "git";
                forwardAgent = true;
                identitiesOnly = true;
              };
              "*" = {
                addKeysToAgent = "yes";
                identityFile =
                  if config.cfi2017.persistence.enable && config.cfi2017.isLinux then
                    "${config.cfi2017.persistence.dataPrefix}/home/${config.cfi2017.user.name}/.ssh/id_ed25519"
                  else
                    "${config.cfi2017.user.homeDirectory}/.ssh/id_ed25519";
                hashKnownHosts = true;
                userKnownHostsFile =
                  if config.cfi2017.persistence.enable && config.cfi2017.isLinux then
                    "${config.cfi2017.persistence.dataPrefix}/home/${config.cfi2017.user.name}/.ssh/known_hosts"
                  else
                    "${config.cfi2017.user.homeDirectory}/.ssh/known_hosts";
              };
            };
          };
        }
        # Enable the ssh-agent service only on Linux machines.
        (lib.mkIf config.cfi2017.isLinux {
          services.ssh-agent = {
            enable = true;
          };
        })
      ];
    }
  ];
}
