declare composerHomeDir
declare composerLock
declare version

preConfigureHooks+=(composerRepositoryConfigureHook)
preBuildHooks+=(composerRepositoryBuildHook)
preCheckHooks+=(composerRepositoryCheckHook)
preInstallHooks+=(composerRepositoryInstallHook)

composerRepositoryConfigureHook() {
    echo "Executing composerRepositoryConfigureHook"

    if [[ -e "$composerLock" ]]; then
        cp $composerLock composer.lock
    fi

    if [[ ! -f "composer.lock" ]]; then
        echo "No composer.lock file found, consider adding one to your repository to ensure reproducible builds."
        composer update --no-install --no-interaction --no-progress
        echo "Using an autogenerated composer.lock file."
    fi

    echo "Finished composerRepositoryConfigureHook"
}

composerRepositoryBuildHook() {
    echo "Executing composerRepositoryBuildHook"

    echo "Finished composerRepositoryBuildHook"
}

composerRepositoryCheckHook() {
    echo "Executing composerRepositoryCheckHook"

    composer validate --no-ansi --no-interaction --no-check-lock

    echo "Finished composerRepositoryCheckHook"
}

composerRepositoryInstallHook() {
    echo "Executing composerRepositoryInstallHook"

    mkdir -p $out

    # Build the local composer repository
    # The command 'build-local-repo' is provided by the Composer plugin
    # drupol/composer-local-repo-plugin.
    composer-local-repo-plugin --no-ansi build-local-repo -r $out

    # Copy the composer.lock files to the output directory, in case it has been
    # autogenerated.
    cp composer.lock $out/

    echo "Finished composerRepositoryInstallHook"
}
