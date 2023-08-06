{
  description = "PHP Composer builder";

  inputs = { };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake =
        {
          overlays.default = final: prev:
            let
              buildComposerProject =
                let
                  composerHooks = prev.callPackages ./src/hooks/default.nix { inherit (prev) php; };

                  composer-local-repo-plugin = prev.callPackage ./src/pkgs/composer-local-repo-plugin.nix {
                    composer = prev.php.packages.composer;
                  };

                  mkComposerRepository = prev.callPackage ./src/build-support/build-composer-repository.nix {
                    inherit composer-local-repo-plugin composerHooks;
                  };
                in
                prev.callPackage ./src/build-support/build-composer-project.nix {
                  inherit composer-local-repo-plugin mkComposerRepository composerHooks;
                };
            in
            {
              api = {
                inherit buildComposerProject;
              };
            };
        };
    };
}
