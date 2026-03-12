{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    flake-compat = {
      url = "github:NixOS/flake-compat";
      flake = false;
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;}
    {
      imports = [
        inputs.git-hooks.flakeModule
      ];
      systems = ["x86_64-linux" "aarch64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        ...
      }: {
        pre-commit.settings.hooks.pretty-format-json.enable = true;

        devShells.default = pkgs.mkShell {
          shellHook = ''
            ${config.pre-commit.shellHook}
          '';

          packages = with pkgs; [corepack nodePackages_latest.nodejs] ++ config.pre-commit.settings.enabledPackages;
        };
      };
    };
}
