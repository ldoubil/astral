{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      rust-overlay,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };
      in
      {
        devShells.default =
          with pkgs;
          mkShell {
            buildInputs = [
              rust-bin.beta.latest.default
              flutter
              rustup
              protobuf
              webkitgtk_4_1
              libayatana-appindicator
            ];

            nativeBuildInputs = [ pkg-config ];

            env = {
              RUST_SRC_PATH = "${rustPlatform.rustLibSrc}";
              LIBCLANG_PATH = "${libclang.lib}/lib";
            };
          };
      }

    );
}
