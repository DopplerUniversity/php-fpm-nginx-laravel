#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
export HOME=/root
export PHP_VERSION='8.0'

log () {
  case $1 in
    info)
      echo -e "\n\e[92m[info]: $2\n"
      ;;

    warn)
      echo -e "\n\e[93m[warn]: $2\n"
      ;;

    error)
      echo -e "\n\e[91m[error]: $2\n"
      ;;

    *)
      echo -e "\n\e[92m[$1]: $2\n"
  esac
}

log info 'Checking for Doppler service token'

if [ -z "$DOPPLER_TOKEN" ]; then
    echo -en 'DOPPLER_TOKEN: ' && read -rs DOPPLER_TOKEN
fi

log info 'Installing system dependencies'
apt-get update && apt-get install -y \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    unzip \
    nano \
    jq \
    cron \
    language-pack-en-base

# Resolves potential issue with adding custom PPA's for php repository - https://github.com/oerdnj/deb.sury.org/issues/56
locale-gen en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Install Doppler CLI
log info 'Installing Doppler CLI'
curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | apt-key add -
echo "deb https://packages.doppler.com/public/cli/deb/debian any-version main" | tee /etc/apt/sources.list.d/doppler-cli.list
apt-get update && apt-get install doppler

log info 'Installing MySQL'
apt-get install mysql-server -y

log info 'Installing PHP'
add-apt-repository ppa:ondrej/php -y
apt-get install "php$PHP_VERSION-fpm" "php$PHP_VERSION-mbstring" "php$PHP_VERSION-dom" -y

log info 'Installing Composer'
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

log info 'Installing NGINX'
apt-get install nginx -y

log info 'Configuring NGINX'
unlink /etc/nginx/sites-enabled/default
cp ./nginx.conf /etc/nginx/sites-available/nginx.conf
ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/nginx.conf

log info 'Configuring Doppler'
doppler configure set token "$DOPPLER_TOKEN" --scope /

log info 'Select env vars solution (dotenv|fpm): ' && read -r ENV_VARS_TYPE
if [ "$ENV_VARS_TYPE" = "dotenv" ]; then
    log info 'dotenv file selected'
    ./bin/dotenv-file.sh
elif [ "$ENV_VARS_TYPE" = "fpm" ]; then
    log info 'php-fpm env vars selected'
    ./bin/php-fpm-vars.sh
else
    log warn 'Option not recognized. Skipping. See bin directory for scripts.'
fi

log info 'Install Laravel dependencies'
cd laravel || exit
composer install

# Start services
service mysql start
service "php$PHP_VERSION-fpm" start
service nginx start

# Optional: Use cron to continually sync secrets, see 'doppler-cron' file
