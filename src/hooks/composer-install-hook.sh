declare composerRepository
declare version
declare composerNoDev
declare composerNoPlugins
declare composerNoScripts

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
        cp "$composerLock" composer.lock
    fi

    if [[ ! -f "composer.lock" ]]; then
        echo "No composer.lock file found, consider adding one to your repository to ensure reproducible builds."

        if [[ -f "${composerRepository}/composer.lock" ]]; then
            cp ${composerRepository}/composer.lock composer.lock
        fi

        echo "Using an autogenerated composer.lock file."
    fi

    chmod +w composer.json composer.lock

    echo "Finished composerInstallConfigureHook"
}

composerInstallBuildHook() {
    echo "Executing composerInstallBuildHook"

    # Since this file cannot be generated in the composer-repository-hook.sh
    # because the file contains hardcoded nix store paths, we generate it here.
    composer-local-repo-plugin --no-ansi build-local-repo -p "${composerRepository}" > packages.json

    # Remove all the repositories of type "composer"
    # from the composer.json file.
    jq -r -c 'del(try .repositories[] | select(.type == "composer"))' composer.json | sponge composer.json

    # Configure composer to disable packagist and avoid using the network.
    composer config repo.packagist false
    # Configure composer to use the local repository.
    composer config repo.composer composer file://"$PWD"/packages.json

    # Since the composer.json file has been modified in the previous step, the
    # composer.lock file needs to be updated.
    COMPOSER_DISABLE_NETWORK=1 \
    COMPOSER_ROOT_VERSION="${version}" \
    composer \
      --lock \
      --no-ansi \
      --no-install \
      --no-interaction \
      ${composerNoDev:+--no-dev} \
      ${composerNoPlugins:+--no-plugins} \
      ${composerNoScripts:+--no-scripts} \
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
    COMPOSER_CACHE_DIR=/dev/null \
    COMPOSER_DISABLE_NETWORK=1 \
    COMPOSER_ROOT_VERSION="${version}" \
    COMPOSER_MIRROR_PATH_REPOS="1" \
    composer \
      --no-ansi \
      --no-interaction \
      ${composerNoDev:+--no-dev} \
      ${composerNoPlugins:+--no-plugins} \
      ${composerNoScripts:+--no-scripts} \
      install

    # Remove packages.json, we don't need it in the store.
    rm packages.json

    # Copy the relevant files only in the store.
    mkdir -p "$out"/share/php/"${pname}"
    cp -r . "$out"/share/php/"${pname}"/

    # Create symlinks for the binaries.
    jq -r -c 'try .bin[]' composer.json | while read -r bin; do
        mkdir -p "$out"/share/php/"${pname}" "$out"/bin
        makeWrapper "$out"/share/php/"${pname}"/"$bin" "$out"/bin/"$(basename "$bin")"
    done

    echo "Finished composerInstallInstallHook"
}
