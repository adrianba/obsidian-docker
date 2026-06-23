#!/bin/sh
set -e

echo "Starting continuous sync..."
exec ob sync --continuous --path /vault
