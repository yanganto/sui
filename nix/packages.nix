{ pkgs, toolchain, self, crane }:
let
  specificRust = pkgs.rust-bin.fromRustupToolchainFile toolchain;
  craneLib = (crane.mkLib pkgs).overrideToolchain (p: specificRust);
  cargoToml = "${self}/Cargo.toml";
  cargoTomlConfig = builtins.fromTOML (builtins.readFile cargoToml);
  version = cargoTomlConfig.workspace.package.version;
  src = self;
  buildInputs = with pkgs; [
    clang
    libclang.lib
    llvmPackages.libcxxClang
    openssl
  ];
  nativeBuildInputs = with pkgs; [ pkg-config ];
  outputHashes = {
    "git+https://github.com/mystenlabs/anemo.git?rev=e609f7697ed6169bf0760882a0b6c032a57e4f3b#e609f7697ed6169bf0760882a0b6c032a57e4f3b" = "sha256-kZaw7j2O4PoMEtJ0TfTV1z8VYw3IgKivEFoqKT4YXGE=";
    "git+https://github.com/nextest-rs/nexlint.git?rev=7ce56bd591242a57660ed05f14ca2483c37d895b#7ce56bd591242a57660ed05f14ca2483c37d895b" = "sha256-L9vf+djTKmcz32IhJoBqAghQ8mS3sc9I2C3BBDdUxkQ=";
    "git+https://github.com/yanganto/tabled/?branch=rm-file-link#d0fb1cdf9ed1ba5bd227da9c7ed261483d56f241" = "sha256-p950gMOOXdZMSV9BT04UQ44HUz9VUeEZcO5EgNYad6c=";
    "git+https://github.com/mystenmark/tokio-madsim-fork.git?rev=d46208cb11118c0e6ab5dfea1a2265add36fbc15#d46208cb11118c0e6ab5dfea1a2265add36fbc15" = "sha256-PoH2DkAGuu51YcUjp3QdeYzjjW0vHlK6weEaKiRjQBo=";
    "git+https://github.com/MystenLabs/fastcrypto?rev=69d496c71fb37e3d22fe85e5bbfd4256d61422b9#69d496c71fb37e3d22fe85e5bbfd4256d61422b9" = "sha256-SL7Qf8yf466t+86yG4MwL9ni4VcRWxnLpEZe11GTp0o=";
    "git+https://github.com/asonnino/prometheus-parser.git?rev=75334db#75334dbe2d286edf6d4424abba92a74643333096" = "sha256-TGiTdewA9uMJ3C+tB+KQJICRW3dSVI0Xcf3YQMfUo6Q=";
    "git+https://github.com/MystenLabs/mysten-sim.git?rev=2a170f4cd81c5cd10f5e4a5e810068f3045f41b6#2a170f4cd81c5cd10f5e4a5e810068f3045f41b6" = "sha256-x6mRX0+Xj7cK9JX4sILiiyAfARnu9CB1whAgVDUzjF4=";
    "git+https://github.com/bmwill/openapiv3.git?rev=ca4b4845b7c159a39f5c68ad8f7f76cb6f4d6963#ca4b4845b7c159a39f5c68ad8f7f76cb6f4d6963" = "sha256-/j2qjyfBYCz6pjcaY6TzB6zDnoxVdxTkZp6rFI2QsUk=";
    "git+https://github.com/nextest-rs/datatest-stable.git?rev=72db7f6d1bbe36a5407e96b9488a581f763e106f#72db7f6d1bbe36a5407e96b9488a581f763e106f" = "sha256-VAdrD5qh6OfabMUlmiBNsVrUDAecwRmnElmkYzba+H0=";
    "git+https://github.com/wlmyng/jsonrpsee.git?rev=b1b300784795f6a64d0fcdf8f03081a9bc38bde8#b1b300784795f6a64d0fcdf8f03081a9bc38bde8" = "sha256-PvuoB3iepY4CLUm9C1EQ07YjFFgzhCmLL1Iix8Wwlns=";
    "git+https://github.com/mystenmark/async-task?rev=4e45b26e11126b191701b9b2ce5e2346b8d7682f#4e45b26e11126b191701b9b2ce5e2346b8d7682f" = "sha256-zMTWeeW6yXikZlF94w9I93O3oyZYHGQDwyNTyHUqH8g=";
    "git+https://github.com/MystenLabs/sui-rust-sdk.git?rev=cb174b66714ea643e4b78bbfadb3f9c17e635460#cb174b66714ea643e4b78bbfadb3f9c17e635460" = "sha256-26KdEH5VqmyDb1Nq9LzesZ4Tat+KA46eonf8ihZYJAY=";
    "git+https://github.com/bmwill/axum-server.git?rev=f44323e271afdd1365fd0c8b0a4c0bbdf4956cb7#f44323e271afdd1365fd0c8b0a4c0bbdf4956cb7" = "sha256-sJLPtFIJAeO6e6he7r9yJOExo8ANS5+tf3IIUkZQXoA=";
  };
  doCheck = false;
  env = {
    GIT_REVISION="unstable";
    LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
    BINDGEN_EXTRA_CLANG_ARGS = "-isystem ${pkgs.llvmPackages.libcxxClang}/resource-root/lib/";
  };
in
rec {
  default = sui;

  sui = craneLib.buildPackage {
    inherit version src env cargoToml buildInputs nativeBuildInputs outputHashes doCheck;
    pname = "sui";
    cargoExtraArgs = "-p sui";
    cargoArtifacts = craneLib.buildDepsOnly {
      inherit version src env cargoToml buildInputs nativeBuildInputs outputHashes doCheck;
      pname = "sui";
      cargoExtraArgs  = "-p sui";
    };
  };

  sui-move = craneLib.buildPackage {
    inherit version src cargoToml outputHashes doCheck;
    pname = "sui-move";
    cargoExtraArgs = "-p sui-move";
    env = env // { CARGO_PROFILE = ""; };
    cargoArtifacts = craneLib.buildDepsOnly {
      inherit version src cargoToml outputHashes doCheck;
      pname = "sui";
      cargoExtraArgs = "-p sui-move";
      env = env // { CARGO_PROFILE = ""; };
    };
  };
}
