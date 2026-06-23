#!/bin/sh
set -e

if [ -z "$OBSIDIAN_EMAIL" ] || [ -z "$OBSIDIAN_PASSWORD" ]; then
  echo "Error: OBSIDIAN_EMAIL and OBSIDIAN_PASSWORD environment variables must be set."
  exit 1
fi

echo "Logging in to Obsidian..."
if [ -n "$OBSIDIAN_MFA" ]; then
  ob login --email "$OBSIDIAN_EMAIL" --password "$OBSIDIAN_PASSWORD" --mfa "$OBSIDIAN_MFA"
else
  ob login --email "$OBSIDIAN_EMAIL" --password "$OBSIDIAN_PASSWORD"
fi

echo "Starting continuous sync..."
exec ob sync --continuous --path /vault
