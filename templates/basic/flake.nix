{
  description = "Example flake for PHP development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-php-composer-builder.url = "github:loophp/nix-php-composer-builder";
  };

  outputs = inputs@{ self, flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

    perSystem = { config, self', inputs', pkgs, system, ... }:
      {
        _module.args.pkgs = import self.inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.nix-php-composer-builder.overlays.default
          ];
          config.allowUnfree = true;
        };

        packages = {
          satis =
            let
              src = pkgs.fetchFromGitHub {
                owner = "composer";
                repo = "satis";
                rev = "23fdf4c1893567c6e46a2cc7fcc868b913f03b28";
                sha256 = "sha256-UMf9/UQl7lK+AG58lBBFkJMpklooWJ4vpAX5ibciFJI=";
              };
            in
            pkgs.api.buildComposerProject {
              inherit src;
              php = pkgs.api.buildPhpFromComposer { inherit src; };

              pname = "statis";
              version = "3.0.0-dev";
              vendorHash = "sha256-TNBPGY58KVamNWuuNcz/RggurDlMWZicrZNVFyel0w8=";
            };
        };

        apps = {
          # nix run .#satis -- --version
          satis = {
            type = "app";
            program = "${(pkgs.writeShellApplication {
                name = "satis";

                text = ''
                  ${inputs.self.packages."${system}".satis}/bin/satis "$@"
                '';
              })}/bin/satis";
          };

          # nix run .#composer -- --version
          composer = {
            type = "app";
            program =
              let
                php = (pkgs.api.buildPhpFromComposer { src = inputs.self; });
              in
              "${(pkgs.writeShellApplication {
                name = "composer";

                text = ''
                  ${php.packages.composer}/bin/composer "$@"
                '';
              })}/bin/composer";
          };
        };
      };

    flake = {
      templates = {
        default = {
          path = ./templates/basic;
          description = "A basic container for getting started with PHP development";
        };
      };
    };
  };
}
