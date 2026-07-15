{
  config,
  pkgs,
  ...
}:
{
  config = {
    home-manager.users.${config.cfi2017.user.name} = {
      programs.pi-coding-agent = {
        enable = true;

        # pi installs extensions as npm packages at runtime, which needs
        # node + bun available on its PATH.
        extraPackages = [
          pkgs.nodejs
          pkgs.bun
        ];

        settings = {
          # LiteLLM provider extension: discovers models from the gateway
          # and registers them under the `litellm` provider.
          packages = [
            "npm:pi-provider-litellm"
            "npm:pi-web-access"
            "npm:@hypabolic/pi-hypa"
            "npm:pi-mcp-adapter"
            "npm:context-mode"
            "npm:pi-subagents"
          ];

          litellm.providers.litellm = {
            baseUrl = "https://slop-gw.gk.wtf/";
            # Auth is supplied interactively via `/login litellm` (stored
            # outside the repo), so no apiKey is declared here.
          };
        };
      };
    };
  };
}
