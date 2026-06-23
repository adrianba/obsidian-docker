#!/bin/sh
set -e

if [ -z "$OBSIDIAN_EMAIL" ] || [ -z "$OBSIDIAN_PASSWORD" ]; then
  echo "Error: OBSIDIAN_EMAIL and OBSIDIAN_PASSWORD environment variables must be set."
  exit 1
fi

echo "Logging in to Obsidian..."
set -- --email "$OBSIDIAN_EMAIL" --password "$OBSIDIAN_PASSWORD"
if [ -n "$OBSIDIAN_MFA" ]; then
  set -- "$@" --mfa "$OBSIDIAN_MFA"
fi
ob login "$@"

echo "Starting continuous sync..."
exec ob sync --continuous --path /vault
