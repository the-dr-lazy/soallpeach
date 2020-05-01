FROM bash

COPY countme /bin/

EXPOSE 80
ENTRYPOINT ["/bin/countme", "+RTS", "-N6", "-A25M", "-RTS"]
