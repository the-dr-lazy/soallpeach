FROM bash

COPY countme /bin/

EXPOSE 80
ENTRYPOINT ["/bin/countme", "+RTS", "-A500M", "-RTS"]
