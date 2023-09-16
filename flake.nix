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
          buildComposerProject = throw "buildComposerProject has been merged upstream in `nixpkgs` and it is no more available within this flake. From now on, please use `php.buildComposerProject` instead.
          ";
        };
      };
    };
  };
}
