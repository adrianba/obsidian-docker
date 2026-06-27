FROM node:22-alpine

RUN npm install -g obsidian-headless

# Pin the config location so it does not depend on the home directory of the
# user running the container. obsidian-headless stores its state (including the
# auth token) under $XDG_CONFIG_HOME/obsidian-headless on Linux.
ENV HOME=/home/node
ENV XDG_CONFIG_HOME=/config

WORKDIR /vault

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Pre-create the mount points owned by uid/gid 1000 (the node user). A newly
# created, empty named volume inherits the ownership of the image directory it
# is first mounted over, so this lets the container run as 1000:1000.
RUN mkdir -p /vault /config \
    && chown 1000:1000 /vault /config

VOLUME ["/vault"]
VOLUME ["/config"]

USER 1000:1000

ENTRYPOINT ["/entrypoint.sh"]
