#!/usr/bin/env bash

APP_DIR='/usr/src/app'

# The 'env-no-quotes' format is required
doppler secrets download --no-file --format env-no-quotes > "$APP_DIR/app.env"
