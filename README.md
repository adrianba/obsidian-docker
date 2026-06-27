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

The container runs as uid/gid `1000:1000` so that vault files are owned by that user on the host. Create the vault directory and make sure it is owned by `1000:1000` before the first run:

```sh
mkdir -p vault && sudo chown -R 1000:1000 vault
```

Run the setup interactively using the published image:

```sh
docker run -it --rm \
  --user 1000:1000 \
  -v ./vault:/vault \
  -v obsidian-config:/config/obsidian-headless \
  --entrypoint sh \
  ghcr.io/adrianba/obsidian-docker:latest \
  -c "ob login && ob sync-setup --vault 'Your Vault Name' --path /vault"
```

This will:
1. Prompt you to log in to your Obsidian account
2. Set up the local `/vault` directory for sync with the named remote vault

The sync configuration is stored in `./vault/.obsidian` and the auth token is stored in the `obsidian-config` named volume (mounted at `/config/obsidian-headless`), so subsequent container runs will use them automatically.

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
  --user 1000:1000 \
  -v ./vault:/vault \
  -v obsidian-config:/config/obsidian-headless \
  ghcr.io/adrianba/obsidian-docker:latest
```

## Building locally

```sh
docker build -t obsidian-docker .
```

## Upgrading from an older image

Earlier versions ran as `root` and stored the auth token in the `obsidian-config`
volume mounted at `/root/.config/obsidian-headless`. The container now runs as
`1000:1000` and reads its config from `/config/obsidian-headless` (via
`XDG_CONFIG_HOME=/config`). The volume is mounted at `/config/obsidian-headless`
— the exact directory obsidian-headless uses — so the contents of an existing
`obsidian-config` volume line up with the new location. To migrate:

- Make sure the host vault directory is owned by `1000:1000`:

  ```sh
  sudo chown -R 1000:1000 vault
  ```

- A pre-existing `obsidian-config` named volume was written while the container
  ran as `root`, so its files are owned by `root` and will not be writable by
  `1000:1000`. Fix the ownership of the volume contents, for example:

  ```sh
  docker run --rm -v obsidian-config:/data alpine chown -R 1000:1000 /data
  ```

  Alternatively, remove the old volume (`docker volume rm obsidian-config`) and
  re-create the auth token by re-running the [first-time setup](#first-time-setup),
  or supply the token directly via the `OBSIDIAN_AUTH_TOKEN` environment variable.

## GitHub Actions

The included workflow (`.github/workflows/docker-publish.yml`) automatically builds and publishes the Docker image to `ghcr.io` on every commit to the `main` branch. The image is tagged with both `latest` and the commit SHA (`sha-<sha>`).
