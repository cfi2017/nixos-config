{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options = {
    cfi2017.development-packages = {
      enable = lib.mkEnableOption "shared development packages";
      tools = {
        c = lib.mkEnableOption "C development";
        go = lib.mkEnableOption "Go development";
        python = lib.mkEnableOption "Python development";
        rust = lib.mkEnableOption "Rust development";
        iac = lib.mkEnableOption "IaC tools";
        k8s = lib.mkEnableOption "Kubernetes tools";
        cloud = lib.mkEnableOption "Cloud tools";
        dev = lib.mkEnableOption "Dev Tools";
        infra = lib.mkEnableOption "Infrastructure tools";
        security = lib.mkEnableOption "Security tools";
        networking = lib.mkEnableOption "Networking tools";
        database = lib.mkEnableOption "Database tools";
      };
    };
  };

  config = lib.mkIf config.cfi2017.development-packages.enable {
    home-manager.users.${config.cfi2017.user.name} = {
      home.packages =
        with pkgs;
        lib.flatten [
          # C Tools
          (lib.optionals config.cfi2017.development-packages.tools.c [
            gcc
            gnumake
          ])
          # Go Tools
          (lib.optionals config.cfi2017.development-packages.tools.go [
            go
            gopls
            golangci-lint
            gosec
            goreleaser
          ])
          # Python Tools
          (lib.optionals config.cfi2017.development-packages.tools.python [
            python3
            python3Packages.python-lsp-server
            python3Packages.python-lsp-ruff
            python3Packages.pwntools
            uv
          ])
          # Rust Tools
          (lib.optionals config.cfi2017.development-packages.tools.rust [
            cargo
            rustc
            clippy
            rustfmt
            rust-analyzer
          ])
          # IaC Tools
          (lib.optionals config.cfi2017.development-packages.tools.iac [
            tenv
            terraform-docs
            tflint
            terraform-ls
            ansible
            ansible-builder
            ansible-lint
            ansible-navigator
          ])
          # K8s Tools
          (lib.optionals config.cfi2017.development-packages.tools.k8s [
            kubectl
            kubernetes-helm
            kustomize
            argocd
            cilium-cli
            hubble
            kubeseal
            talosctl
            kube-linter
            kubescape
            helm-docs
            dive
            k3d
            kind
            rakkess
            drawio
            prometheus-alertmanager
            pkgs.stable.kyverno-chainsaw
            # azure
            kubelogin

            kubectl-cnpg
            kubectl-tree
            kubectl-rook-ceph
            kubectl-gadget
            kubectl-neat
            kubectl-explore
            kubectl-doctor
            kubectl-validate
            kubectl-evict-pod
            kubectl-node-shell
            kubectl-view-allocations

            # oidc-login
            kubelogin-oidc
          ])
          # Cloud CLI Tools
          (lib.optionals config.cfi2017.development-packages.tools.cloud [
            awscli2
            azure-cli
            hcloud
            minio-client
          ])
          # Dev Tools
          (lib.optionals config.cfi2017.development-packages.tools.dev [
            devenv
            httpie
            nodejs
            pre-commit
            just
            bats
            yaml-language-server
            powershell
            act
            bun
            jujutsu
            jjui
          ])
          # Infrastructure Tools
          (lib.optionals config.cfi2017.development-packages.tools.infra [
            packer
            boundary
            consul
            nomad
          ])
          # Security Tools
          (lib.optionals config.cfi2017.development-packages.tools.security [
            vault
            openbao
            inputs.ida-pro-flake.packages.${system}.ida-pro
            # inputs.binaryninja-flake.packages.${system}.binaryninja
            inputs.burpsuite.packages.${system}.default
            # inputs.berg-cli.packages.${system}.default
            gdb
            ngrok
            pwncat
            frp
            rustscan
            remmina
            gobuster
            sqlmap
            proxychains
            metasploit
          ])
          # Database Tools
          (lib.optionals config.cfi2017.development-packages.tools.database [ postgresql ])
        ];
    };
  };
}
