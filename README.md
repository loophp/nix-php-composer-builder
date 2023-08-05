# Nix PHP Composer builder

A Nix builder for PHP projects that uses [Composer](https://getcomposer.org/).

## History

The development of this PHP builder started in April 2023.
The objective was to create a totally new PHP builder capable of building PHP
projects using Composer. Given that Composer, despite its excellent package
management capabilities, lacks the ability to create reproducible builds out of
the box, this task posed a significant challenge.

[A pull request](https://github.com/NixOS/nixpkgs/pull/225401) was initiated
against `nixpkgs` and it is currently awaiting for reviews. The entire history
of the PR is also accessible there.

Simultaneously, I have separated the relevant parts and files of this PR into
this current project. This not only allows for greater flexibility in
implementing it into existing flakes but also facilitates its enhancement and
foster user contributions.

The idea is that each improvements that are made in this project will be merged
to some extent in the upstream PR against `nixpkgs`.

Once this builder will be merged in `nixpkgs`, there will be no reason to keep
this repository alive and it will be archived.

## Usage

### Step 1

Add this input to your flake:

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

## Examples

### Packaging Drupal

<details>

```nix
drupal = pkgs.api.buildComposerProject {
  inherit php;

  pname = "drupal";
  version = "11.x-dev";

  src = pkgs.fetchFromGitHub {
    owner = "drupal";
    repo = "drupal";
    rev = "aec9cf8ca15958546b882f8eb371080dbd39b9ed";
    sha256 = "sha256-GzGm1X5uKCqkKowWCce7xOjgGa9uDzywSMGJlorNLlY=";
  };

  vendorHash = "sha256-CJtf7r3EhjZTL2vKGXokqy1+uONNq+bA+wGrDmeqIRs=";
};
```

</details>

### Packaging `symfony/demo`

<details>

```nix
symfony-demo = pkgs.api.buildComposerProject {
  pname = "symfony-demo";
  version = "2.3.0-dev";

  src = pkgs.fetchFromGitHub {
    owner = "symfony";
    repo = "demo";
    rev = "e8a754777bd400ecf87e8c6eeea8569d4846d357";
    sha256 = "sha256-ZG0O8O4X5t/GkAVKhcedd3P7WXYiZ0asMddX1XfUVR4=";
  };

  vendorHash = "sha256-Nv9pRQJ2Iij1IxPNcCk732Q79FWB/ARJRvjPVVyLMEc=";
};
```

</details>

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
