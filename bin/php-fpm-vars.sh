#!/usr/bin/env bash

# Usage
# 
# Filter out vars with empty value
# ./bin/php-fpm-vars.sh --filter-empty
#
# Nullify value for for vars with empty value
# ./bin/php-fpm-vars.sh --nullify-empty

PHP_VERSION='8.0'
VARS_FILE="/etc/php/$PHP_VERSION/fpm/pool.d/z-doppler-vars.conf"

touch "$VARS_FILE"
SECRETS_SHA=$(sha256sum "$VARS_FILE")

# Save Doppler secrets to PHP-FPM conf file
# NOTE: Must be loaded after the existing pool conf file (hence the naming)
echo -e "[info]: Creating $VARS_FILE"

# The php ini syntax is weird in that it doesn't support unquoted values with characters such as '!', or mixed case values of 'no', 'false', or 'null'.
# While we figure out the best way to handle values, provide two options: strip empty vars or set value to "null"

if [ -z "$1" ]; then
    echo "[error]: Must specify empty var handling with either '--filter-empty' or '--nullify-empty'"
elif [ "$1" = "--filter-empty" ]; then
    echo '[info]: Filtering out vars with empty values'
    doppler secrets download --no-file --format json | jq -r '. | to_entries[] | select(.value != "") | "env[\(.key)] = \"\(.value)\""' > "$VARS_FILE"    
elif [ "$1" = "--nullify-empty" ]; then
    echo '[info]: Nullifying vars with empty values'
    doppler secrets download --no-file --format json | jq -r '. | to_entries[] | "env[\(.key)] = \"\(.value // null)\""' > "$VARS_FILE"
else
    echo "[error]: Unknown option '$1' supplied for handling empty values"
fi

NEW_SECRETS_SHA=$(sha256sum "$VARS_FILE")

# Restart PHP-FPM service if secrets have changed
if [ "$SECRETS_SHA" != "$NEW_SECRETS_SHA" ]; then
    service php$PHP_VERSION-fpm restart
fi
