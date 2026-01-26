# Clawdbot sandbox Docker image
#
# This builds a Docker image that Clawdbot uses to isolate shell execution
# from spawned agents. Equivalent to upstream's Dockerfile.sandbox but
# built reproducibly via Nix.
#
# Usage:
#   nix build .#clawdbot-sandbox
#   docker load < result

{ pkgs }:

pkgs.dockerTools.buildImage {
  name = "clawdbot-sandbox";
  tag = "bookworm-slim";

  copyToRoot = pkgs.buildEnv {
    name = "sandbox-root";
    paths = with pkgs; [
      bashInteractive
      cacert
      coreutils
      curl
      git
      jq
      python3
      ripgrep
    ];
    pathsToLink = [ "/bin" "/etc" ];
  };

  config = {
    Cmd = [ "sleep" "infinity" ];
    Env = [ "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];
  };
}
