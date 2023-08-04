{ pkgs
, php
, jq
, moreutils
, ...
}:

{
  composerRepositoryHook = pkgs.makeSetupHook
    {
      name = "composer-repository-hook.sh";
      propagatedBuildInputs = [ php jq moreutils ];
      substitutions = { };
    } ./composer-repository-hook.sh;

  composerInstallHook = pkgs.makeSetupHook
    {
      name = "composer-install-hook.sh";
      propagatedBuildInputs = [ php jq moreutils ];
      substitutions = { };
    } ./composer-install-hook.sh;
}
