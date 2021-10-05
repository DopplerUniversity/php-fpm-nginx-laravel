#!/usr/bin/env bash

##################
# DOPPLER CONFIG #
##################

export DOPPLER_TOKEN='dp.st.prd.xxxx' # Replace with your service token
export ENV_VARS_TYPE="fpm-vars" # Can also be "dotenv" but 'fpm-vars' is recommended as env vars file is only temporary saved to disk

#################
# SCRIPT CONFIG #
#################

export DEBIAN_FRONTEND=noninteractive
export HOME=/root
export PHP_VERSION='8.0'
export WORKDIR='/usr/src/app'

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

########
# INIT #
########

log info 'Checking out sample code repository: https://github.com/DopplerUniversity/php-fpm-nginx-laravel.git'
git clone https://github.com/DopplerUniversity/php-fpm-nginx-laravel.git $WORKDIR

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
systemctl enable --now mysql

log info 'Installing PHP'
add-apt-repository ppa:ondrej/php -y
apt-get install "php$PHP_VERSION-fpm" "php$PHP_VERSION-mbstring" "php$PHP_VERSION-dom" -y
systemctl enable "php$PHP_VERSION-fpm"

log info 'Installing Composer'
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

log info 'Installing and configuring NGINX'
apt-get install nginx -y
unlink /etc/nginx/sites-enabled/default
ln -s $WORKDIR/nginx.conf /etc/nginx/sites-enabled/doppler.conf
systemctl enable --now nginx

# TODO: Get Apache working with php-fpm
# log info 'Installing and configuring Apache'
# apt-get install apache2 -y
# a2dissite 000-default
# ln -s $WORKDIR/apache.conf /etc/apache2/sites-enabled/doppler.conf
# a2enmod proxy_fcgi setenvif
# a2enconf "php$PHP_VERSION-fpm"
# systemctl status apache2

log info 'Configuring Doppler using service token'
doppler configure set token "$DOPPLER_TOKEN" --scope /
doppler secrets --only-names

log info 'Allow www-data user to write to required directories'
chown -R www-data:www-data "$WORKDIR/laravel/storage"
mkdir -p $WORKDIR/laravel/vendor && chown -R www-data:www-data $WORKDIR/laravel/vendor
chown -R www-data:www-data "$WORKDIR/laravel/bootstrap/cache"

log info 'Install Laravel dependencies'
cd $WORKDIR/laravel || exit
composer install --no-scripts --no-interaction
cd $WORKDIR

log info 'Set env vars'
if [ "$ENV_VARS_TYPE" = "dotenv" ]; then
    log info 'dotenv file selected'
    ./bin/dotenv-file.sh
elif [ "$ENV_VARS_TYPE" = "fpm-vars" ]; then
    log info 'php-fpm env vars selected'
    ./bin/php-fpm-vars.sh --remove-empty
else
    log warn 'Option not recognized. Skipping. See bin directory for scripts.'
fi

log info "NGINX php-fpm site available at http://$(curl https://ipinfo.io/ip):9090/"
# Optional: Use cron to continually sync secrets, see the './doppler-cron' file
