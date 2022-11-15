{
  description = "web service that scrapes hydro";

  inputs = {
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = github:edolstra/flake-compat;
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, flake-compat, fenix }: flake-utils.lib.eachDefaultSystem
    (system:
      let
        revision = "${self.lastModifiedDate}-${self.shortRev or "dirty"}";

        # pkgs = nixpkgs.legacyPackages.${system};
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };


        buildInputs = [
          pkgs.openssl
        ];
        frontend = (pkgs.makeRustPlatform {
            inherit (fenix.packages.${system}.minimal) cargo rustc;
        }).buildRustPackage {
            pname = "hive-frontend";
            version = revision;
            doCheck = false;
            src = ./.;
            # cargoSha256 = nixpkgs.lib.fakeSha256;

            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;

            cargoSha256 = "sha256-d7pRXXVSkqhLEzEp+39IDkeQlAsqS4KuTPWxnliVbSo=";
          };
        # ruby = pkgs.ruby_3_1;

        # rubyEnv = pkgs.bundlerEnv {
        #   name = "hydro-bundler-env";
        #   inherit ruby;
        #   gemdir = ./.;
        #   gemset = ./nix/gemset.nix;
        #   groups = ["default" "development" "test"];

        #   gemConfig.nokogiri = attrs: {
        #     buildInputs = [ pkgs.libiconv pkgs.zlib ];
        #   };

        #   gemConfig.openssl = attrs: {
        #     buildInputs = [ pkgs.openssl ];
        #   };
        # };

        #hydrofetch = pkgs.stdenv.mkDerivation {
        #  name = "hydrofetch-${self.shortRev or "dirty"}";

        #  nativeBuildInputs = [ rubyEnv ];
        #  propagatedBuildInputs = [ ];

        #  src = builtins.path {
        #    filter = path: type: type != "directory" || baseNameOf path != "archive";
        #    path = ./.;
        #    name = "src";
        #  };

        #  dontBuild = true;

        #  installPhase = ''
        #    mkdir -p $out/{bin,share/hydrofetch}
        #    cp -r * $out/share/hydrofetch

        #    bin=$out/bin/hydrofetch
        #    cat > $bin <<EOF
##!/bin/sh -e
#exec ${rubyEnv}/bin/bundle exec $out/share/hydrofetch/exe/hydrofetch "\$@"
#EOF
        #    chmod +x $bin

        #    debugbin=$out/bin/dev
        #    cat > $debugbin <<EOF
##!/bin/sh -e
#exec ${rubyEnv}/bin/bundle exec ${ruby}/bin/irb -I $out/share/hydrofetch/lib -r hydrofetch
#EOF
        #    chmod +x $debugbin
        #  '';
        #};

        # hydrofetchDockerImage = pkgs.dockerTools.buildImage {
        #   name = "hydrofetch";
        #   tag = revision;
        #   # fromImage = buildChromeBase;
        #   fromImage = chromeBaseImage;
        #   copyToRoot = pkgs.buildEnv {
        #     name = "image-root";
        #     pathsToLink = [ "/bin" ];
        #     paths = with pkgs.dockerTools; [
        #       pkgs.which
        #       pkgs.bashInteractive
        #       pkgs.coreutils
        #       rubyEnv
        #       hydrofetch
        #     ];
        #   };
        #   config = {
        #     Cmd = [
        #       "/bin/hydrofetch"
        #       "server"
        #     ];
        #     ExposedPorts = {
        #       "8080/tcp" = { };
        #     };
        #   };
        #   extraCommands = ''
        #     mkdir -p tmp
        #   '';
        # };
      in
      {

        devShells.default = with pkgs; mkShell {
          buildInputs = [
            # rubyEnv (lowPrio rubyEnv.wrappedRuby) skopeo pkgs.chromedriver # hydrofetch
            frontend
          ];
        };

        packages = {
          # ociImage = hydrofetchDockerImage;
          # default = rubyEnv;
          default = frontend;
        };
      });
}
