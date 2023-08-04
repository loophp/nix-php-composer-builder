declare composerHomeDir
declare composerRepository
declare version

preConfigureHooks+=(composerInstallConfigureHook)
preBuildHooks+=(composerInstallBuildHook)
preCheckHooks+=(composerInstallCheckHook)
preInstallHooks+=(composerInstallInstallHook)

composerInstallConfigureHook() {
    echo "Executing composerInstallConfigureHook"

    if [[ ! -e "${composerRepository}" ]]; then
        echo "No local composer repository found."
        exit 1
    fi

    if [[ -e "$composerLock" ]]; then
        cp $composerLock composer.lock
    fi

    if [[ ! -f "composer.lock" ]]; then
        echo "No composer.lock file found"
        exit 1
    fi

    chmod +w composer.json composer.lock
    cp composer.json composer.json.orig

    echo "Finished composerInstallConfigureHook"
}

composerInstallBuildHook() {
    echo "Executing composerInstallBuildHook"

    # Since this file cannot be generated in the composer-repository-hook.sh
    # because the file contains hardcoded nix store paths, we generate it here.
    composer-local-repo-plugin --no-ansi build-local-repo -p ${composerRepository} > packages.json

    # Configure composer to disable packagist and avoid using the network.
    composer config repo.packagist false
    # Configure composer to use the local repository.
    composer config repo.composer composer file://$PWD/packages.json

    # Since the composer.json file has been modified in the previous step, the
    # composer.lock file needs to be updated.
    COMPOSER_ROOT_VERSION="${version}" \
    composer \
      --lock \
      --no-ansi \
      --no-install \
      --no-interaction \
      --no-plugins \
      --no-scripts \
      update

    echo "Finished composerInstallBuildHook"
}

composerInstallCheckHook() {
    echo "Executing composerInstallCheckHook"

    composer validate --no-ansi --no-interaction

    echo "Finished composerInstallCheckHook"
}

composerInstallInstallHook() {
    echo "Executing composerInstallInstallHook"

    # Finally, run `composer install` to install the dependencies and generate
    # the autoloader.
    # The COMPOSER_ROOT_VERSION environment variable is needed only for
    # vimeo/psalm.
    COMPOSER_ROOT_VERSION="${version}" \
    COMPOSER_MIRROR_PATH_REPOS="1" \
    composer \
      --no-ansi \
      --no-interaction \
      --no-scripts \
      install

    # Remove packages.json, we don't need it in the store.
    rm packages.json

    # Copy the relevant files only in the store.
    mkdir -p $out/share/php/${pname}
    cp -r . $out/share/php/${pname}/

    # Create symlinks for the binaries.
    jq -r -c 'try .bin[]' composer.json | while read bin; do
        mkdir -p $out/share/php/${pname} $out/bin
        ln -s $out/share/php/${pname}/$bin $out/bin/$(basename $bin)
    done

    mv composer.json.orig composer.json

    echo "Finished composerInstallInstallHook"
}
