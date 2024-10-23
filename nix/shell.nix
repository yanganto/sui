{ pkgs, toolchain }:
let
  specificRust = pkgs.rust-bin.fromRustupToolchainFile toolchain;
in
{
  # Dev shell for following binaries
  # anemo-benchmark, cut, import-trace, move-analyzer, sui-framework-snapshot,
  # sui-light-client, sui-metric-checker, sui-move, sui-oracle, sui-proxy,
  # sui-source-validation-service, sui-test-validator, suiop
  core = pkgs.mkShell ({
    name = "core";
    buildInputs = with pkgs; [specificRust ];
    DEV_SHELL_NAME = "core";
  });

  # Dev shell for most binaies
  # NOTE: sui-aws-orchestrator needs addtional dependency aws-sdk-ec2
  default = pkgs.mkShell ({
    buildInputs = with pkgs; [
      specificRust
      openssl
    ];
    nativeBuildInputs = with pkgs; [
      clang
      libclang.lib
      llvmPackages.libcxxClang
      pkg-config
    ];
    DEV_SHELL_NAME = "sui";
    LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
    BINDGEN_EXTRA_CLANG_ARGS = "-isystem ${pkgs.llvmPackages.libcxxClang}/resource-root/lib/";
  });
}
