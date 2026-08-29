{ inputs, ... }:
{
  additions = final: prev: import ../pkgs { pkgs = final; };
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable { system = prev.stdenv.hostPlatform.system; };
  };

  package-fixes =
    final: prev:
    let
      # mattermost-api 90000.1.1 predates crypton-connection 0.4's extra
      # TLSSettingsSimple argument. This is upstream PR #65, plus the explicit
      # Haskell dependency that hackage2nix cannot infer from a patched cabal
      # file. Rebuild the QC package against the same library so Matterhorn's
      # test suite does not see two different mattermost-api derivations.
      mattermost-api = prev.haskell.lib.overrideCabal prev.haskellPackages.mattermost-api (old: {
        patches = (old.patches or [ ]) ++ [ ../patches/mattermost-api-crypton-connection-0.4.patch ];
        libraryHaskellDepends = (old.libraryHaskellDepends or [ ]) ++ [ prev.haskellPackages.tls ];
        broken = false;
      });
      mattermost-api-qc = prev.haskellPackages.mattermost-api-qc.override {
        inherit mattermost-api;
      };
      matterhorn = prev.haskellPackages.matterhorn.override {
        inherit mattermost-api mattermost-api-qc;
      };
    in
    {
      goobook = prev.goobook.overridePythonAttrs (old: {
        pythonRelaxDeps = (old.pythonRelaxDeps or [ ]) ++ [ "simplejson" ];
      });

      matterhorn = prev.haskell.lib.compose.justStaticExecutables (
        prev.haskell.lib.doJailbreak matterhorn
      );
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
