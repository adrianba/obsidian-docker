FROM node:22-alpine

RUN npm install -g obsidian-headless

WORKDIR /vault

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/vault"]
VOLUME ["/root/.config/obsidian-headless"]

ENTRYPOINT ["/entrypoint.sh"]
