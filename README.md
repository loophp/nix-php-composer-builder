# Nix PHP Composer builder

A Nix builder for PHP projects that uses [Composer](https://getcomposer.org/).

## History

The development of this PHP builder started in April 2023. The objective was to
create a totally new PHP builder capable of building PHP projects using
Composer. Given that Composer, despite its excellent package management
capabilities, lacks the ability to create reproducible builds out of the box,
this task posed a significant challenge.

[A pull request](https://github.com/NixOS/nixpkgs/pull/225401) was initiated
against `nixpkgs` and it is currently awaiting for reviews. The entire history
of the PR is also accessible there.

Simultaneously, I have separated the relevant parts and files of this PR into
this current project. This not only allows for greater flexibility in
implementing it into existing flakes but also facilitates its enhancement and
foster user contributions.

The idea is that each improvements that are made in this project will be merged
to some extent in the upstream PR against `nixpkgs`. Once the PR will be merged
in `nixpkgs`, there will be no reason to keep this repository alive and it will
be archived.

## Usage

This flake provides a default template to get you started quickly. To use it,
run:

```bash
nix flake init --template github:loophp/nix-php-composer-builder#basic
```

Read more about the [basic template](templates/basic/README.md).

However, you can follow the steps below for a more manual approach:

<details>

<summary>Step 1</summary>

Add a new input to your own flake:

```nix
{
  description = "My PHP project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Add the following line
    nix-php-composer-builder.url = "github:loophp/nix-php-composer-builder";
  };

  ...

}
```

</details>

<details>

<summary>Step 2</summary>

This flake provides a default overlay, import it in your own flake:

```nix
pkgs = import inputs.nixpkgs {
    inherit system;
    overlays = [
        inputs.nix-php-composer-builder.overlays.default
    ];
};
```

</details>

<details>

<summary>Step 3</summary>

Use the `buildComposerProject` function to build your project:

```nix
myPhpProject = pkgs.api.buildComposerProject {
    # Customize the version of PHP you want to use.
    # inherit php;

    pname = "my-php-project";
    version = "1.0.0";

    src = ; # Your src

    vendorHash = "sha256-O2+ner833dlj0JSg/paBXcrgk1SuRF6hIdZ7Pn+MCx4=";
};
```

</details>

## Examples

See examples on how to package [Drupal](https://github.com/drupal/drupal),
[Framework-X](https://github.com/clue/framework-x),
[Mezzio Skeleton](https://github.com/mezzio/mezzio-skeleton),
[Satis](https://github.com/composer/satis) or
[Symfony Demo](https://github.com/symfony/demo) in the
[checks.nix](./tests/checks.nix) file.

Those derivations are also used in the tests to ensure that the builds are
consistent.

## Extra

This flake provides a `buildPhpFromComposer` function, which is designed to
generate an adequate PHP environment from an existing `composer.json` file. It
ensures that the extensions specified within the `composer.json` file are
correctly installed.

Instead of doing:

```nix
php = php.withExtensions({enabled, all}: enabled ++ [ all.xsl all.pcov ]);
```

You can now just do:

```nix
php = pkgs.api.buildPhpFromComposer { inherit src; };
```

As long as your `composer.json` list the required extensions in the `require` or
`require-dev` sections, as such:

```json
{
  # ...8<...
  "require": {
    "ext-xsl": "*",
    "ext-pcov": "*"
  }
  # ...>8...
}
```

To modify the PHP configuration, create a file `.user.ini` in the project with
your custom PHP configuration directives:

```ini
memory_limit=-1
```

## Testing

To evaluate this new PHP/Composer builder, a few PHP derivations provided as
examples have been written. As the objective of this builder is to guarantee
reproducible PHP builds, conducting the tests essentially boils down to just
building these derivations.

To run the tests, execute the following command:

```shell
nix flake check ./tests --no-write-lock-file
```

## Contributing

Feel free to contribute by sending pull requests. We are a usually very
responsive team and we will help you going through your pull request from the
beginning to the end.

For some reasons, if you can't contribute to the code and willing to help,
sponsoring is a good, sound and safe way to show us some gratitude for the hours
we invested in this package.

Sponsor me on [Github][github sponsors link] and/or any of [the
contributors][6].

[github sponsors link]: https://github.com/sponsors/drupol
[6]: https://github.com/loophp/collection/graphs/contributors
