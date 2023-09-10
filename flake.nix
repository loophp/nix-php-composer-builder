{
  description = "PHP Composer builder";

  outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ ];

    flake = {
      templates = {
        basic = {
          path = ./templates/basic;
          description = "A basic template for getting started with PHP development";
          welcomeText = builtins.readFile ./templates/basic/README.md;
        };
      };

      overlays.default = final: prev: {
        api = {
          buildPhpFromComposer = prev.callPackage ./src/build-support/build-php-from-composer.nix { };

          buildComposerProject =
            let
              composerHooks = prev.callPackages ./src/hooks/default.nix { };

              mkComposerRepository = prev.callPackage ./src/build-support/build-composer-repository.nix {
                inherit composerHooks;
              };
            in
            prev.callPackage ./src/build-support/build-composer-project.nix {
              inherit composerHooks mkComposerRepository;
            };
        };
      };
    };
  };
}
