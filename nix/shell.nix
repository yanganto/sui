{ pkgs, toolchain, packages }:
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
    buildInputs = [ specificRust ];
    DEV_SHELL_NAME = "sui#core";
  });

  # Dev shell for most binaies
  # NOTE: sui-aws-orchestrator needs addtional dependency aws-sdk-ec2
  dev = pkgs.mkShell ({
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
    DEV_SHELL_NAME = "sui#dev";
    LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
    BINDGEN_EXTRA_CLANG_ARGS = "-isystem ${pkgs.llvmPackages.libcxxClang}/resource-root/lib/";
  });

  # A shell with full sui command
  default = pkgs.mkShell ({
    buildInputs = with packages; [ sui ];
    DEV_SHELL_NAME = "sui#default";
  });

  # A slim shell focus on contract development
  slim = pkgs.mkShell ({
    buildInputs = with packages; [ sui-move ];
    DEV_SHELL_NAME = "sui#slim";
  });
}
