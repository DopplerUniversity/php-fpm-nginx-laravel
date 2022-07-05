#!/usr/bin/env bash

set -e -u -o pipefail

PHP_INI_FILE="$PHP_INI_DIR/php.ini-production"
CONFIG="$(doppler secrets get DOPPLER_CONFIG --plain)"

echo -e "[info]: using Doppler $CONFIG environment"

if [ "$CONFIG" == 'dev' ]
then
    PHP_INI_FILE="$PHP_INI_DIR/php.ini-development"
fi

echo -e "[info]: selected $PHP_INI_FILE configuration file"
mv "$PHP_INI_FILE" "$PHP_INI_DIR/php.ini"

echo -e "[info]: configuring application"
if test -f ".env"; then
    rm -f .env
fi

./bin/sync-secrets.sh

DB_FORCE_MIGRATE="$(doppler secrets get DB_FORCE_MIGRATE --plain)"
if [ "$DB_FORCE_MIGRATE" == 'TRUE' ]
then
    php artisan migrate --force
fi

echo -e "[info]: executing command php-fpm"

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

exec "$@"
