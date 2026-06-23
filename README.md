# obsidian-docker

A Docker container that runs [obsidian-headless](https://github.com/obsidianmd/obsidian-headless) in continuous sync mode. Keeps an Obsidian vault in sync with [Obsidian Sync](https://obsidian.md/sync) without requiring the desktop app.

## Prerequisites

- An active [Obsidian Sync](https://obsidian.md/sync) subscription
- A remote vault already created in Obsidian Sync
- A local vault directory configured for sync (see [First-time setup](#first-time-setup))

## Image

The image is published to the GitHub Container Registry:

```
ghcr.io/adrianba/obsidian-docker:latest
```

## First-time setup

Before running the container, you need to configure the local vault directory for sync. This is a one-time step that stores the sync configuration in the vault's `.obsidian` directory.

Run the setup interactively using the published image:

```sh
docker run -it --rm \
  -v ./vault:/vault \
  --entrypoint sh \
  ghcr.io/adrianba/obsidian-docker:latest \
  -c "ob login && ob sync-setup --vault 'Your Vault Name' --path /vault"
```

This will:
1. Prompt you to log in to your Obsidian account
2. Set up the local `/vault` directory for sync with the named remote vault

The sync configuration is stored in `./vault/.obsidian`, so subsequent container runs will use it automatically.

## Usage

### With Docker Compose (recommended)

1. Copy the sample compose file:

   ```sh
   cp docker-compose.yml my-compose.yml
   ```

2. Start the container:

   ```sh
   docker compose -f my-compose.yml up -d
   ```

### With Docker run

```sh
docker run -d \
  --restart unless-stopped \
  -v ./vault:/vault \
  ghcr.io/adrianba/obsidian-docker:latest
```

## Building locally

```sh
docker build -t obsidian-docker .
```

## GitHub Actions

The included workflow (`.github/workflows/docker-publish.yml`) automatically builds and publishes the Docker image to `ghcr.io` on every commit to the `main` branch. The image is tagged with both `latest` and the commit SHA (`sha-<sha>`).
