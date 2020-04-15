#!/usr/bin/env bash
set -euo pipefail

export here=$(dirname "${BASH_SOURCE[0]}")

nixConf() {
  sudo mkdir -p /etc/nix
  # Workaround a segfault: https://github.com/NixOS/nix/issues/2733
  sudo sh -c 'echo http2 = false >> /etc/nix/nix.conf'
  # Set jobs to number of cores
  sudo sh -c 'echo max-jobs = auto >> /etc/nix/nix.conf'
  # Allow binary caches for runner user
  sudo sh -c 'echo trusted-users = root runner >> /etc/nix/nix.conf'
}

nixConf

# Needed due to multi-user being too defensive
export ALLOW_PREEXISTING_INSTALLATION=1

sh <(curl -L https://nixos.org/nix/install) --daemon

# write nix.conf again as installation overwrites it
nixConf

# Reload the daemon to pick up changes
sudo pkill -HUP nix-daemon

# Set paths
export $PATH=/nix/var/nix/profiles/per-user/runner/profile/bin:$PATH
export $PATH=/nix/var/nix/profiles/default/bin:$PATH
export $NIX_PATH=/nix/var/nix/profiles/per-user/root/channels

while ! nc -zU /nix/var/nix/daemon-socket/socket; do sleep 1; done
