FROM haskell:8.8.3

COPY . .

RUN cabal new-update
RUN cabal new-build --ghc-options="-O2"
RUN cabal new-install

ENTRYPOINT ["prime"]
