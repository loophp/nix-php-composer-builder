{
  description = "PHP Composer builder";

  outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ ];

    flake =
      {
        templates = {
          basic = {
            path = ./templates/basic;
            description = "A basic container for getting started with PHP development";
            welcomeText = ''
              # Simple PHP/Composer Template

              ## Intended usage

              This template is designed to provide a basic flake template for
              PHP development.

              When using this template, two new files will be created in your
              project:

              - `flake.nix`: A default flake file for your project, containing
                the basic configuration for starting PHP development.
              - `flake.lock`: A lock file to lock the versions of the
                dependencies like `php` and `composer`. Use `nix flake update`
                to update them at your convenience.

              Features of this flake template include:

              - A default `PHP development shell` with PHP and Composer.
                Use it with: `nix develop .`
              - The `composer` flake application.
                Use it with: `nix run .#composer -- --version`
              - The `satis` package provided as example on how to bundle a PHP
                application.
              - The `satis` flake application provided as example.
                Use it with: `nix run .#satis -- --version`

              For each features, Nix will detect the required extensions for PHP
              by reading the `composer.json` file. As long as your
              `composer.json` file list the required extensions in the
              `require` or `require-dev` sections, no any other configuration is
              needed on your part.

              If you need to modify the PHP configuration, create a file
              `.user.ini` in the project with your custom PHP configuration
              directives.

              For more customizations, feel free to edit the `flake.nix` file
              and add your own changes; the possibilities are endless.

              Happy hacking !
            '';
          };
        };

        overlays.default = final: prev: {
          api = {
            buildPhpFromComposer = prev.callPackage ./src/build-support/build-php-from-composer.nix { };

            buildComposerProject =
              let
                composerHooks = prev.callPackages ./src/hooks/default.nix { };

                composer-local-repo-plugin = prev.callPackage ./src/pkgs/composer-local-repo-plugin.nix {
                  inherit (prev.php.packages) composer;
                };

                mkComposerRepository = prev.callPackage ./src/build-support/build-composer-repository.nix {
                  inherit composer-local-repo-plugin composerHooks;
                };
              in
              prev.callPackage ./src/build-support/build-composer-project.nix {
                inherit composer-local-repo-plugin mkComposerRepository composerHooks;
              };
          };
        };
      };
  };
}
