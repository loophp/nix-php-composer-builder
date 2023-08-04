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
                  composerHooks = prev.callPackages ./nix/hooks/default.nix { inherit (prev) php; };

                  composer-local-repo-plugin = prev.callPackage ./nix/composer-local-repo-plugin.nix {
                    composer = prev.php.packages.composer;
                  };

                  mkComposerRepository = prev.callPackage ./nix/build-composer-repository.nix {
                    inherit composer-local-repo-plugin composerHooks;
                  };
                in
                prev.callPackage ./nix/build-composer-project.nix {
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
