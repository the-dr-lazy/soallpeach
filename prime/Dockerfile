FROM haskell:8.8.3

RUN mkdir -p /opt/prime
WORKDIR /opt/prime

COPY *.cabal ./

RUN cabal new-update
RUN cabal new-build --dependencies-only

COPY . .

RUN cabal new-build --ghc-options="-O2"
RUN cabal new-install

ENTRYPOINT ["prime"]
