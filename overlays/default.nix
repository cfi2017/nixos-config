{ inputs, ... }:
{
  additions = final: prev: import ../pkgs { pkgs = final; };
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable { system = prev.stdenv.hostPlatform.system; };
  };

  force-latest =
    final: prev:
    let
      master = import inputs.nixpkgs-master {
        system = prev.stdenv.hostPlatform.system;
        overlays = [ ];
      };
    in
    {
      nix-init = master.nix-init;
      nurl = master.nurl;
      nix = master.nix;
    };

  citrix_workspace =
    final: prev:
    let
      old = import inputs.nixpkgs-25-05 {
        system = prev.stdenv.hostPlatform.system or prev.system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      citrix-workspace = prev.citrix-workspace.overrideAttrs (oa: {
        buildInputs = (oa.buildInputs or [ ]) ++ [ old.webkitgtk_4_0 ];
        meta = (oa.meta or { }) // {
          broken = false;
        };
      });
    };
}
