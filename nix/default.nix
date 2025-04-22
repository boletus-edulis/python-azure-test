{
  pythonVersion,
  pythonPackages,
}:

let
  overlay = final: prev: {
    pythonPackagesOverlays = (prev.pythonPackagesOverlays or [ ]) ++ [
      (python-final: python-prev: {
        azure-mgmt-resourcegraph = python-final.callPackage ./azure-mgmt-resourcegraph { };
        # pip builds doc using sphinx and sphinx issues
        # sphinx-issues needs ghc
        # ghc does not build on musl aarch64
        #
        # pip = (python-prev.pip.overrideAttrs (oldAttrs: {
        #   postBuild = "";
        #   postInstall = "";
        #   outputs = [
        #     "out"
        #     "dist"
        #   ];
        # })).override {
        #   sphinx = null;
        #   sphinx-issues = null;
        # };
      })
    ];

    "${pythonVersion}" =
      let
        self = prev."${pythonVersion}".override {
          inherit self;
          packageOverrides = prev.lib.composeManyExtensions final.pythonPackagesOverlays;
        };
      in
      self;

    "${pythonPackages}" = final."${pythonVersion}".pkgs;
  };
in
{
  inherit overlay;
}
