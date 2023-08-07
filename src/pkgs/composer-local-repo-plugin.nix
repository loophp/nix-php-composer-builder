{ fetchFromGitHub
, lib
, makeBinaryWrapper
, php
, stdenvNoCC
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "composer-local-repo-plugin";
  version = "40bfd0c52439d89994e7414299493a097705a541";

  src = fetchFromGitHub {
    owner = "drupol";
    repo = "composer-local-repo-plugin";
    rev = finalAttrs.version;
    hash = "sha256-nSjAicyvStVoBFm7SJy4EYQIwrAaLjm72XMgsPF3CSg=";
  };

  COMPOSER_CACHE_DIR = "/dev/null";
  COMPOSER_MIRROR_PATH_REPOS = "1";
  COMPOSER_HTACCESS_PROTECT = "0";
  COMPOSER_DISABLE_NETWORK = "1";

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  buildInputs = [
    php.packages.composer
  ];

  configurePhase = ''
    runHook preConfigure

    export COMPOSER_HOME=${placeholder "out"}

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    # Configure composer globally
    composer global init --quiet --no-interaction --no-ansi \
      --name="nixos/composer" \
      --homepage "https://nixos.org/" \
      --description "Composer with drupol/composer-local-repo-plugin" \
      --license "MIT"

    composer global config --quiet minimum-stability dev
    composer global config --quiet prefer-stable true
    composer global config --quiet autoloader-suffix "nixPredictableAutoloaderSuffix"
    composer global config --quiet apcu-autoloader false
    composer global config --quiet allow-plugins.drupol/composer-local-repo-plugin true
    composer global config --quiet repo.packagist false
    composer global config --quiet repo.plugin path $src

    # Install the local repository plugin
    composer global require --quiet --no-ansi --no-interaction drupol/composer-local-repo-plugin

    runHook postBuild
  '';

  checkPhase = ''
    runHook preCheck

    composer global validate --no-ansi
    composer global show --no-ansi drupol/composer-local-repo-plugin

    runHook postCheck
  '';

  installPhase =
    let
      composerKeys = stdenvNoCC.mkDerivation (finalComposerKeysAttrs: {
        pname = "composer-keys";
        version = "fa5a62092f33e094073fbda23bbfc7188df3cbc5";

        src = fetchFromGitHub {
          owner = "composer";
          repo = "composer.github.io";
          rev = "${finalComposerKeysAttrs.version}";
          hash = "sha256-3Sfn71LDG1jHwuEIU8iEnV3k6D6QTX7KVIKVaNSuCVE=";
        };

        installPhase = ''
          runHook preInstall

          mkdir -p $out
          install releases.pub $out/keys.tags.pub
          install snapshots.pub $out/keys.dev.pub

          runHook postInstall
        '';
      });
    in
    ''
      runHook preInstall

      mkdir -p $out
      cp -ar ${composerKeys}/* $out/

      makeWrapper ${php.packages.composer}/bin/composer $out/bin/composer-local-repo-plugin \
        --prefix COMPOSER_HOME : $out

      runHook postInstall
    '';

  meta = {
    description = "Composer local repo plugin for Composer";
    license = lib.licenses.mit;
    homepage = "https://github.com/drupol/composer-local-repo-plugin";
    maintainers = lib.teams.php.members;
    platforms = lib.platforms.all;
  };
})
