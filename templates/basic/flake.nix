{
  description = "Example flake for PHP development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-php-composer-builder.url = "github:loophp/nix-php-composer-builder";
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs@{ self, flake-parts, systems, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import systems;

    perSystem = { config, self', inputs', pkgs, system, lib, ... }:
      let
        php = pkgs.api.buildPhpFromComposer { src = inputs.self; };
      in
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
                hash = "sha256-UMf9/UQl7lK+AG58lBBFkJMpklooWJ4vpAX5ibciFJI=";
              };
            in
            pkgs.api.buildComposerProject {
              inherit src;
              php = pkgs.api.buildPhpFromComposer { inherit src; };

              pname = "statis";
              version = "3.0.0-dev";
              vendorHash = "sha256-TNBPGY58KVamNWuuNcz/RggurDlMWZicrZNVFyel0w8=";

              meta.mainProgram = "satis";
            };
        };

        devShells.default = pkgs.mkShellNoCC {
          name = "php-devshell";
          buildInputs = [
            php
            php.packages.composer
            php.packages.phpstan
            php.packages.psalm
            pkgs.phpunit
            self'.packages.satis
          ];
        };

        apps = {
          # nix run .#satis -- --version
          satis = {
            type = "app";
            program = "${(pkgs.writeShellApplication {
              name = "satis";

              text = ''
                ${lib.getExe self'.packages.satis} "$@"
              '';
            })}/bin/satis";
          };

          # nix run .#composer -- --version
          composer = {
            type = "app";
            program = "${(pkgs.writeShellApplication {
              name = "composer";

              runtimeInputs = [
                php
                php.packages.composer
              ];

              text = ''
                ${lib.getExe php.packages.composer} "$@"
              '';
            })}/bin/composer";
          };

          # nix run .#phpunit -- --version
          phpunit = {
            type = "app";
            program = "${(pkgs.writeShellApplication {
              name = "phpunit";

              runtimeInputs = [
                php
              ];

              text = ''
                ${lib.getExe pkgs.phpunit} "$@"
              '';
            })}/bin/phpunit";
          };

          # nix run .#phpstan -- --version
          phpstan = {
            type = "app";
            program = "${(pkgs.writeShellApplication {
              name = "phpstan";

              runtimeInputs = [
                php
                php.packages.phpstan
              ];

              text = ''
                ${lib.getExe php.packages.phpstan} "$@"
              '';
            })}/bin/phpstan";
          };

          # nix run .#psalm -- --version
          psalm = {
            type = "app";
            program = "${(pkgs.writeShellApplication {
              name = "psalm";

              runtimeInputs = [
                php
                php.packages.psalm
              ];

              text = ''
                ${lib.getExe php.packages.psalm} "$@"
              '';
            })}/bin/psalm";
          };
        };
      };
  };
}
