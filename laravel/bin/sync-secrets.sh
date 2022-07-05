#!/usr/bin/env bash

set -e -u -o pipefail

echo "[info]: checking for secret updates [$(date -u +"%Y-%m-%d %H:%M:%S")]"

sync_secrets() {
    echo -e '[info]: syncing latest secrets\n'
    doppler run --mount .env --command 'sha256sum .env > .secrets_sha; php artisan config:cache'
}

if ! test -f ".secrets_sha"; then
    sync_secrets
    exit 0
fi

SECRETS_SHA=$(<.secrets_sha)
NEW_SECRETS_SHA="$(doppler run --mount .env -- sha256sum .env)"

if [ "$SECRETS_SHA" != "$NEW_SECRETS_SHA" ]; then
    sync_secrets
else
    echo '[info]: secrets are up to date'
fi
