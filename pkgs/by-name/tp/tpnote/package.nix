{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cmake,
  pkg-config,
  oniguruma,
  darwin,
  installShellFiles,
  tpnote,
  testers,
}:

rustPlatform.buildRustPackage rec {
  pname = "tpnote";
  version = "1.24.12";

  src = fetchFromGitHub {
    owner = "getreu";
    repo = "tp-note";
    rev = "v${version}";
    hash = "sha256-1Y7Sw9wiUno4A6i0lYDJpqfIT/HV5rxXfuJnJ+FJTBU=";
  };

  cargoHash = "sha256-ZOE2D8GXrJ7BQK7iMoUnqyrj4zc+ODJxZ1jgH7xYMI0=";

  nativeBuildInputs = [
    cmake
    pkg-config
    installShellFiles
  ];

  buildInputs =
    [
      oniguruma
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin (
      with darwin.apple_sdk.frameworks;
      [
        AppKit
        CoreServices
        SystemConfiguration
      ]
    );

  postInstall = ''
    installManPage docs/build/man/man1/tpnote.1
  '';

  RUSTONIG_SYSTEM_LIBONIG = true;

  passthru.tests.version = testers.testVersion { package = tpnote; };

  # The `tpnote` crate has no unit tests. All tests are in `tpnote-lib`.
  checkType = "debug";
  cargoTestFlags = "--package tpnote-lib";
  doCheck = true;

  meta = {
    changelog = "https://github.com/getreu/tp-note/releases/tag/v${version}";
    description = "Markup enhanced granular note-taking";
    homepage = "https://blog.getreu.net/projects/tp-note/";
    license = lib.licenses.mit;
    mainProgram = "tpnote";
    maintainers = with lib.maintainers; [ getreu ];
  };
}
