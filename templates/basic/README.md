# Basic PHP/Composer template

## Intended usage

This template is designed to provide a basic flake template for
PHP development.

When using this template, four new files will be created in your project:

- `flake.nix`: A default flake file for your project, containing
  the basic configuration for starting PHP development.
- `flake.lock`: A lock file to lock the versions of the
  dependencies like `php` and `composer`. Use `nix flake update`
  to update them at your convenience.
- `_README_.md`: This file.
- `.envrc`: A file used by `direnv` that will automatically load the development
  environment.

Features of this flake template include:

- A default flake development shell with PHP and Composer. If you're using
  `direnv`, it will be automatically loaded. Otherwise use it
  with: `nix develop .`
- The `composer` flake application.
  Use it with: `nix run .#composer -- --version`
- The `satis` flake package provided as example on how to bundle a PHP
  application.
- The `satis` flake application provided as example.
  Use it with: `nix run .#satis -- --version`

For each features, Nix will detect the required extensions for PHP
by reading the `composer.json` file. As long as your
`composer.json` file list the required extensions in the
`require` or `require-dev` sections, no any other configuration is
needed on your part.

If you need to modify the PHP configuration, create a file
`.user.ini` in the project with your custom PHP configuration
directives.

For more customizations, feel free to edit the `flake.nix` file
and add your own changes; the possibilities are endless.

Happy hacking !
