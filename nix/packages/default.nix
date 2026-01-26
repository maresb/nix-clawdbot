{ pkgs
, sourceInfo ? import ../sources/clawdbot-source.nix
, steipetePkgs ? {}
, toolNamesOverride ? null
, excludeToolNames ? []
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  toolSets = import ../tools/extended.nix {
    pkgs = pkgs;
    steipetePkgs = steipetePkgs;
    inherit toolNamesOverride excludeToolNames;
  };
  clawdbotGateway = pkgs.callPackage ./clawdbot-gateway.nix {
    inherit sourceInfo;
    pnpmDepsHash = sourceInfo.pnpmDepsHash or null;
  };
  clawdbotApp = if isDarwin then pkgs.callPackage ./clawdbot-app.nix { } else null;
  clawdbotTools = pkgs.buildEnv {
    name = "clawdbot-tools";
    paths = toolSets.tools;
    pathsToLink = [ "/bin" ];
  };
  clawdbotBundle = pkgs.callPackage ./clawdbot-batteries.nix {
    clawdbot-gateway = clawdbotGateway;
    clawdbot-app = clawdbotApp;
    extendedTools = toolSets.tools;
  };
  # Docker sandbox image (Linux only)
  clawdbotSandbox = if pkgs.stdenv.hostPlatform.isLinux
    then pkgs.callPackage ./clawdbot-sandbox.nix {}
    else null;
in {
  clawdbot-gateway = clawdbotGateway;
  clawdbot = clawdbotBundle;
  clawdbot-tools = clawdbotTools;
} // (if isDarwin then { clawdbot-app = clawdbotApp; } else {})
  // (if pkgs.stdenv.hostPlatform.isLinux then { clawdbot-sandbox = clawdbotSandbox; } else {})
