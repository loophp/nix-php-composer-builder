{
  outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ ];

    flake = {
      templates = {
        basic = throw "The template is now available from `https://github.com/loophp/nix-shell`.";
      };

      overlays.default = final: prev: {
        api = {
          buildPhpFromComposer = throw "buildPhpFromComposer has been merged upstream in `https://github.com/loophp/nix-shell` and it is no more available within this flake.";
          buildComposerProject = throw "buildComposerProject has been merged upstream in `nixpkgs` and it is no more available within this flake. From now on, please use `php.buildComposerProject` instead.";
        };
      };
    };
  };
}
