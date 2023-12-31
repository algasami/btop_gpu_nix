{
  description = "A wrapper for btop_gpu";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils/4022d587cbbfd70fe950c1e2083a02621806a725";
    btop_src = {
      url = "github:aristocratos/btop/285fb215d12a5e0c686b29e1039027cbb2b246da";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, btop_src, flake-utils, ... }:
  let

    lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";
    version = builtins.substring 0 0 lastModifiedDate;

  in flake-utils.lib.eachDefaultSystem (system:
    let
      name = "btop_gpu";
      src = ./.;
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    in
    {
      packages.default = with pkgs; stdenv.mkDerivation {
        inherit system name src version;
        buildPhase = ''
          mkdir -p $out/build
          cp -r ${btop_src}/* $out/build
          cd $out/build && make GPU_SUPPORT=true
        '';
        installPhase = ''
          cd $out/build && make install PREFIX=$out
        '';

        # runtime dependencies
        buildInputs = with pkgs; [];

        # build-time dependencies
        nativeBuildInputs = with pkgs; [
          gnumake
          coreutils
        ];
      };
    }
  );
}
