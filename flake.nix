{
  description = "web service that scrapes hydro";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = github:edolstra/flake-compat;
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, flake-compat }: flake-utils.lib.eachDefaultSystem
    (system:
      let
        revision = "${self.lastModifiedDate}-${self.shortRev or "dirty"}";

        # pkgs = nixpkgs.legacyPackages.${system};
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        frontend = pkgs.rustPlatform.buildRustPackage rec {
          pname = "hive-frontend";
          version = "beta";

          doCheck = false;

          src = builtins.path {
            filter = path: type: type != "directory" || baseNameOf path != "archive";
            path = ./frontend;
            name = "src";
          };

          cargoSha256 = "03wf9r2csi6jpa7v5sw5lpxkrk4wfzwmzx7k3991q3bdjzcwnnwp";

          # meta = with flake-utils.lib; {
          #   description = "A fast line-oriented regex search tool, similar to ag and ack";
          #   homepage = "https://github.com/BurntSushi/ripgrep";
          # };
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
