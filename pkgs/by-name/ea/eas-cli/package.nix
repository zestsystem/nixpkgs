{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  patchelf,
  nodejs,
  jq,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "eas-cli";
  version = "14.7.1";

  src = fetchFromGitHub {
    owner = "expo";
    repo = "eas-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-h7LohShs4j9Z7Mbe6MSMqfszrEPBcGeTpB+ma3iBXyM=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock"; # Point to the root lockfile
    hash = "sha256-pnp9MI2S5v4a7KftxYC3Sgc487vooX8+7lmYkmRTWWs=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    nodejs
    patchelf
    jq
  ];

  # yarnInstallHook strips out build outputs within packages/eas-cli resulting in most commands missing from eas-cli.
  installPhase = ''
    mkdir -p $out/lib/node_modules/eas-cli-root
    yarn install --immutable --immutable-cache --offline --non-interactive --production --frozen-lockfile
    cp -r . $out/lib/node_modules/eas-cli-root
  '';

  postFixup = ''
    mkdir -p $out/bin
    ln -sf $out/lib/node_modules/eas-cli-root/packages/eas-cli/bin/run $out/bin/eas
  '';

  meta = {
    changelog = "https://github.com/expo/eas-cli/releases/tag/v${finalAttrs.version}";
    description = "EAS command line tool from submodule";
    homepage = "https://github.com/expo/eas-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zestsystem ];
  };
})
