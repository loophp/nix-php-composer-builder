{
  description = "PHP Composer builder";

  inputs = { };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake =
        {
          overlays.default = final: prev:
            let
              buildComposerProject = php:
                let
                  composerHooks = prev.callPackages ./nix/hooks/default.nix { inherit php; };

                  composer-local-repo-plugin = prev.callPackage ./nix/composer-local-repo-plugin.nix {
                    composer = php.packages.composer;
                  };

                  mkComposerRepository = prev.callPackage ./nix/build-composer-repository.nix {
                    inherit php composer-local-repo-plugin composerHooks;
                  };
                in
                prev.callPackage ./nix/build-composer-project.nix {
                  inherit php composer-local-repo-plugin mkComposerRepository composerHooks;
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
