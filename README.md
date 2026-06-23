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

1. Copy the sample compose file and configure it:

   ```sh
   cp docker-compose.yml my-compose.yml
   ```

2. Create a `.env` file with your credentials:

   ```env
   OBSIDIAN_EMAIL=your@email.com
   OBSIDIAN_PASSWORD=yourpassword
   ```

3. Start the container:

   ```sh
   docker compose -f my-compose.yml up -d
   ```

### With Docker run

```sh
docker run -d \
  --restart unless-stopped \
  -e OBSIDIAN_EMAIL=your@email.com \
  -e OBSIDIAN_PASSWORD=yourpassword \
  -v ./vault:/vault \
  ghcr.io/adrianba/obsidian-docker:latest
```

## Environment variables

| Variable | Required | Description |
|---|---|---|
| `OBSIDIAN_EMAIL` | Yes | Obsidian account email |
| `OBSIDIAN_PASSWORD` | Yes | Obsidian account password |
| `OBSIDIAN_MFA` | No | One-time TOTP code for initial login (if your account has 2FA enabled) |

> **Note on MFA**: TOTP codes are typically valid for 30 seconds. If your account has MFA enabled, the container must complete login before the code expires. For a long-running container, consider performing the initial vault setup interactively (see [First-time setup](#first-time-setup)) so that login credentials are cached, and then restart the container without `OBSIDIAN_MFA`.

> **Security note**: `OBSIDIAN_EMAIL` and `OBSIDIAN_PASSWORD` are passed as arguments to the `ob login` command, which means they may appear in process listings on the host. This is a limitation of the current `ob` CLI interface. Use Docker secrets or a secrets manager when possible, and ensure the host has appropriate access controls.

## Building locally

```sh
docker build -t obsidian-docker .
```

## GitHub Actions

The included workflow (`.github/workflows/docker-publish.yml`) automatically builds and publishes the Docker image to `ghcr.io` on every commit to the `main` branch. The image is tagged with both `latest` and the commit SHA (`sha-<sha>`).
