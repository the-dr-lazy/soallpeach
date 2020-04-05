FROM nixos/nix
MAINTAINER Mohammad Hasani <thebrodmann@protonmail.com>

RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
RUN nix-channel --update

COPY . .

RUN nix-build -A production

ENTRYPOINT ["./result/bin/prime"]
