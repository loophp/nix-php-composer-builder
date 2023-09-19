{ pkgs
}: let
  php = pkgs.php82;
in {
  clue-framework-x = php.buildComposerProject {
    pname = "clue-framework-x";
    version = "1.0.0-dev";

    src = pkgs.fetchFromGitHub {
      owner = "clue";
      repo = "framework-x";
      rev = "277e9a582c90042e3e32c7ef045123848ef147fc";
      hash = "sha256-wtMJcNwxvqGKtrr8Ak4ON4b9jMwBGlBUs+S2M8iSHf4=";
    };

    vendorHash = "sha256-ER5l3MjPmdPZ/85bRcf2dOHKL1tBG9stQc8n3YsCerg=";
  };

  drupal =
    let
      src = pkgs.fetchFromGitHub {
        owner = "drupal";
        repo = "drupal";
        rev = "72e7c019993f7d8491de277c66f40354a0967b00";
        hash = "sha256-nrR+jj8wCTN2RLWxik19emEGyVqzoBiUo6aAfNQZG8Q=";
      };

      php = pkgs.api.buildPhpFromComposer {
        inherit src;
      };
    in
    php.buildComposerProject {
      inherit src;

      pname = "drupal";
      version = "11.0.0-dev";
      vendorHash = "sha256-39cCLG4x8/C9XZG2sOCpxO1HUsqt3DduCMMIxPCursw=";
    };

  mezzio-skeleton = php.buildComposerProject {
    pname = "mezzio-skeleton";
    version = "3.15.0-dev";

    src = pkgs.fetchFromGitHub {
      owner = "mezzio";
      repo = "mezzio-skeleton";
      rev = "2eb90de8cd7b8efb1b31d505385ce92c17153608";
      hash = "sha256-D3jmCcYXpH92r6yvn/2SlQ1G9yd/izHJjcYfunk/jjA=";
    };

    vendorHash = "sha256-ltN6qHeV34oDUt0c5XBPsoKYvIcWf4Q6FQNRymcKFoU=";
  };

  satis = php.buildComposerProject {
    pname = "satis";
    version = "3.0.0-dev";

    src = pkgs.fetchFromGitHub {
      owner = "composer";
      repo = "satis";
      rev = "23fdf4c1893567c6e46a2cc7fcc868b913f03b28";
      hash = "sha256-UMf9/UQl7lK+AG58lBBFkJMpklooWJ4vpAX5ibciFJI=";
    };

    vendorHash = "sha256-YA5UIlGhRVdkz+NFiujGRkb9Zx8Up4IEOmco1rEOkGk=";

    meta.mainProgram = "satis";
  };

  symfony-demo = php.buildComposerProject {
    pname = "symfony-demo";
    version = "2.3.0-dev";

    src = pkgs.fetchFromGitHub {
      owner = "symfony";
      repo = "demo";
      rev = "e8a754777bd400ecf87e8c6eeea8569d4846d357";
      hash = "sha256-ZG0O8O4X5t/GkAVKhcedd3P7WXYiZ0asMddX1XfUVR4=";
    };

    vendorHash = "sha256-tbVvhFUNaMR5xwB/zpvHjnNiqJWHjNnQDY+s6IXQmcU=";
  };
}
