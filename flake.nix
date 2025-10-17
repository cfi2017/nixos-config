{
  description = "cfi2017 NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    nixpkgs-master.url = "github:nixos/nixpkgs";

    # core flakes
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = { url = "github:nix-community/impermanence"; };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland / Wayland flakes
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpaper = {
      url = "github:hyprvm/hyprpaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Catpuccin theming
    nix-colors = { url = "github:misterio77/nix-colors"; };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Others
    nur.url = "github:nix-community/NUR";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Documentation
    ndg.url = "github:feel-co/ndg";
  };

  outputs = { self, nixpkgs, home-manager, impermanence, hyprland, hyprpaper
    , hyprlock, nur, nix-colors, catppuccin, sops-nix, ndg, pre-commit-hooks
    , ... }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];

      lib = system:
        nixpkgs.lib.recursiveUpdate (import ./lib {
          pkgs = nixpkgs.legacyPackages.${system};
          lib = nixpkgs.lib;
        }) nixpkgs.lib;

      # TODO: this
      sharedModules = [ ];
      nixosModules = [ ];

    in {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          rawModules = [
            ./modules/shared
            ./modules/nixos # Linux specific
          ];
        in (import ./pkgs { inherit pkgs; }) // {
          docs = ndg.packages.${system}.ndg-builder.override {
            title = "cfi2017 - Nix systems";
            inputDir = ./docs;
            rawModules = rawModules;
            optionsDepth = 3;
          };
        });

      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = with pkgs;
            mkShell {
              inherit (self.checks.${system}.pre-commit-check) shellHook;
              NIX_CONFIG = "experimental-features = nix-command flakes";
            };
        });

      formatter = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in pkgs.nixfmt-rfc-style);

      checks = forAllSystems (system: {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            statix.enable = false;
            nixfmt-rfc-style.enable = true;
          };
        };
      });

      overlays = import ./overlays { inherit inputs; };

      nixosConfigurations = {
        e14 = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
            lib = lib "x86_64-linux";
          };
          modules = sharedModules ++ nixosModules
            ++ [ ./machines/e14/default.nix ];
        };
      };
    };
}
