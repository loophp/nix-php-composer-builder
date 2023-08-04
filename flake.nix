{
  description = "PHP Composer builder";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake =
        {
          api.buildComposerProject = pkgs: php:
            let
              composerHooks = pkgs.callPackages ./nix/hooks/default.nix { inherit php; };

              composer-local-repo-plugin = pkgs.callPackage ./nix/composer-local-repo-plugin.nix {
                composer = php.packages.composer;
              };

              mkComposerRepository = pkgs.callPackage ./nix/build-composer-repository.nix {
                inherit php composer-local-repo-plugin composerHooks;
              };
            in
            pkgs.callPackage ./nix/build-composer-project.nix {
              inherit php composer-local-repo-plugin mkComposerRepository composerHooks;
            };
        };
    };
}
