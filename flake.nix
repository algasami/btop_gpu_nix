{
  description = "A wrapper for btop_gpu";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils/4022d587cbbfd70fe950c1e2083a02621806a725";
    btop_src = {
      url = "github:aristocratos/btop?ref=main&shallow=1";
      # need the latest package
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
      src = btop_src;
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    in
    {
      packages.default = with pkgs; stdenv.mkDerivation {
        inherit system name src version;
        buildPhase = ''
          make GPU_SUPPORT=true
        '';
        installPhase = ''
          mkdir $out
          make install PREFIX=$out
        '';

        # TODO: This is only for fix. I should fix it soon
        postFixup = ''
          patchelf \
          --add-needed /run/opengl-driver/lib/libnvidia-ml.so \
          $out/bin/btop
        '';

        # runtime dependencies
        buildInputs = with pkgs; [];

        # build-time dependencies
        nativeBuildInputs = with pkgs; [
          gnumake
          coreutils
          patchelf
        ];
      };
    }
  );
}
