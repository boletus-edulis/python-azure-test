{
  description = "Python development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      treefmt-nix,
      ...
    }:
    let
      eachSystem =
        f:
        nixpkgs.lib.genAttrs (import systems) (
          system:
          f (
            import nixpkgs {
              inherit system;
            }
          )
        );

      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

      pythonVersion = "python313";
      pythonPackages = "${pythonVersion}Packages";

      #localNix = import ./nix { inherit pythonVersion pythonPackages; };

      legacyPackages = eachSystem (pkgs: {
        inherit pkgs;
      });
    in
    {
      inherit legacyPackages;
      inherit pythonVersion pythonPackages;

      packages = eachSystem (pkgs: {
        default = pkgs.callPackage ./nix/justatest.nix {
          src = ./python;
          pythonPackages = pkgs.${pythonPackages};
          azure-mgmt-resourcegraph = pkgs.${pythonPackages}.callPackage ./nix/azure-mgmt-resourcegraph { };
        };
      });

      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.nixfmt-rfc-style
            (pkgs.${pythonVersion}.withPackages (
              pythonPackages:
              with pythonPackages;
              [
                pip
                black
                flake8
                jedi
                distutils
                setuptools
                python-lsp-ruff
              ]
              ++ self.packages.${pkgs.system}.default.propagatedBuildInputs
            ))
          ];
        };
      });

      dockerImage = eachSystem (pkgs: {
        default = pkgs.dockerTools.buildImage {
          name = "hello";
          tag = "latest";
          created = "now";
          copyToRoot = pkgs.buildEnv {
            name = "image-root";
            paths = [ pkgs.hello ];
            pathsToLink = [ "/bin" ];
          };

          config.Cmd = [ "/bin/hello" ];
        };
      });
    };
}
