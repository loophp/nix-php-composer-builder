# Nix PHP Composer builder

A Nix builder for PHP projects that uses [Composer](https://getcomposer.org/).

## History

The work on this PHP builder started the 9th of April 2023. The goal was to have
a PHP builder that is able to build PHP projects using Composer.

A PR against `nixpkgs` has been created at
https://github.com/NixOS/nixpkgs/pull/225401 and is waiting for reviews.

In the meantime, I've extracted the relevant part of that PR into this project,
so we can have more flexibility to use it in existing flakes, but also to
improve it.

The idea is that each improvements that are made in this project will be merged
to some extent in the PR against `nixpkgs`.

## Usage

### Step 1

Add this input to your flake:

```nix
{
  description = "CAS Lib";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-php-composer-builder.url = "github:loophp/nix-php-composer-builder";
  };

  ...

}
```

### Step 2

Import the overlay:

```nix
pkgs = import inputs.nixpkgs {
    inherit system;
    overlays = [
        inputs.nix-php-composer-builder.overlays.default
    ];
};
```

### Step 3

Use the `buildComposerProject` function to build your project:

```nix
packages.default = pkgs.api.buildComposerProject {
    # Customize the version of PHP you want to use.
    # inherit php;

    pname = "my-php-project";
    version = "1.0.0";

    src = ; # Your src

    vendorHash = "sha256-O2+ner833dlj0JSg/paBXcrgk1SuRF6hIdZ7Pn+MCx4=";
};
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
