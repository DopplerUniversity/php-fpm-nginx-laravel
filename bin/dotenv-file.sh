#!/usr/bin/env bash

WORKDIR='/usr/src/app'

# The 'env-no-quotes' format is required
doppler secrets download --no-file --format env-no-quotes > "$WORKDIR/app.env"
