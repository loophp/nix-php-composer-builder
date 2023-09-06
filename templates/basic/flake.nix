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
        php = pkgs.api.buildPhpFromComposer {
          src = inputs.self;
          php = pkgs.php81; # Change to php81, php82, php83 etc.
        };
      in
      {
        _module.args.pkgs = import self.inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.nix-php-composer-builder.overlays.default
          ];
          config.allowUnfree = true;
        };

        checks = {
          inherit (self'.packages) drupal satis symfony-demo;
        };

        apps = {
          symfony-demo = {
            type = "app";
            program = lib.getExe (pkgs.writeShellApplication {
              name = "php-symfony-demo";

              runtimeInputs = [
                php
              ];

              text = ''
                APP_CACHE_DIR=$(mktemp -u)/cache
                APP_LOG_DIR=$APP_CACHE_DIR/log
                DATABASE_URL=sqlite:///$APP_CACHE_DIR/database.sqlite

                export APP_CACHE_DIR
                export APP_LOG_DIR
                export DATABASE_URL

                mkdir -p "$APP_CACHE_DIR"
                mkdir -p "$APP_LOG_DIR"

                cp -f ${self'.packages.symfony-demo}/share/php/symfony-demo/data/database.sqlite "$APP_CACHE_DIR"/database.sqlite
                chmod +w "$APP_CACHE_DIR"/database.sqlite

                ${lib.getExe pkgs.symfony-cli} serve --document-root ${self'.packages.symfony-demo}/share/php/symfony-demo/public --allow-http
              '';
            });
          };
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

              pname = "satis";
              version = "3.0.0-dev";
              vendorHash = "sha256-YA5UIlGhRVdkz+NFiujGRkb9Zx8Up4IEOmco1rEOkGk=";

              meta.mainProgram = "satis";
            };

          drupal =
            let
              src = pkgs.fetchFromGitHub {
                owner = "drupal";
                repo = "drupal";
                rev = "72e7c019993f7d8491de277c66f40354a0967b00";
                hash = "sha256-nrR+jj8wCTN2RLWxik19emEGyVqzoBiUo6aAfNQZG8Q=";
              };
            in
            pkgs.api.buildComposerProject {
              inherit src;
              php = pkgs.api.buildPhpFromComposer { inherit src; };

              pname = "drupal";
              version = "11.0.0-dev";
              vendorHash = "sha256-39cCLG4x8/C9XZG2sOCpxO1HUsqt3DduCMMIxPCursw=";
            };

          symfony-demo =
            let
              src = pkgs.fetchFromGitHub {
                owner = "symfony";
                repo = "demo";
                rev = "e8a754777bd400ecf87e8c6eeea8569d4846d357";
                hash = "sha256-ZG0O8O4X5t/GkAVKhcedd3P7WXYiZ0asMddX1XfUVR4=";
              };
            in pkgs.api.buildComposerProject {
              pname = "symfony-demo";
              version = "1.0.0";

              inherit src;

              composerNoDev = false;
              composerNoPlugins = false;

              php = pkgs.api.buildPhpFromComposer { inherit src; };

              vendorHash = "sha256-Nv9pRQJ2Iij1IxPNcCk732Q79FWB/ARJRvjPVVyLMEc=";
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
            program = lib.getExe (pkgs.writeShellApplication {
              name = "satis";

              text = ''
                ${lib.getExe self'.packages.satis} "$@"
              '';
            });
          };

          # nix run .#composer -- --version
          composer = {
            type = "app";
            program = lib.getExe (pkgs.writeShellApplication {
              name = "composer";

              runtimeInputs = [
                php
                php.packages.composer
              ];

              text = ''
                ${lib.getExe php.packages.composer} "$@"
              '';
            });
          };

          # nix run .#grumphp -- --version
          grumphp = {
            type = "app";
            program = lib.getExe (pkgs.writeShellApplication {
              name = "grumphp";

              runtimeInputs = [
                php
              ];

              text = ''
                ${lib.getExe php.packages.grumphp} "$@"
              '';
            });
          };

          # nix run .#phpunit -- --version
          phpunit = {
            type = "app";
            program = lib.getExe (pkgs.writeShellApplication {
              name = "phpunit";

              runtimeInputs = [
                php
              ];

              text = ''
                ${lib.getExe pkgs.phpunit} "$@"
              '';
            });
          };

          # nix run .#phpstan -- --version
          phpstan = {
            type = "app";
            program = lib.getExe (pkgs.writeShellApplication {
              name = "phpstan";

              runtimeInputs = [
                php
                php.packages.phpstan
              ];

              text = ''
                ${lib.getExe php.packages.phpstan} "$@"
              '';
            });
          };

          # nix run .#psalm -- --version
          psalm = {
            type = "app";
            program = lib.getExe (pkgs.writeShellApplication {
              name = "psalm";

              runtimeInputs = [
                php
                php.packages.psalm
              ];

              text = ''
                ${lib.getExe php.packages.psalm} "$@"
              '';
            });
          };
        };
      };
  };
}
