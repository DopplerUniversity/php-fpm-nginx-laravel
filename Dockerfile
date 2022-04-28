FROM ubuntu:20.04

ARG PHP_VERSION="8.0"
ENV LANG="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV TZ="America/Los_Angeles"
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    curl \
    mysql-client \
    nginx \
    gnupg \
    lsb-release \
    git \
    unzip \
    nano \
    jq \
    cron \
    language-pack-en-base \
    locales

# Resolves potential issue with adding custom PPA's for php repository - https://github.com/oerdnj/deb.sury.org/issues/56
RUN locale-gen en_US.UTF-8

# Install PHP
RUN add-apt-repository ppa:ondrej/php -y && \
    apt-get install "php${PHP_VERSION}-fpm" "php${PHP_VERSION}-mbstring" "php${PHP_VERSION}-dom" -y && \
    systemctl enable "php${PHP_VERSION}-fpm"

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Doppler CLI
RUN curl -Ls --tlsv1.2 --proto "=https" --retry 3 https://cli.doppler.com/install.sh | sh

# Copy code and install dependencies
COPY bin/php-fpm-vars.sh /usr/local/bin/doppler-php-fpm-vars
COPY laravel ./
RUN composer install --no-scripts --no-interaction

# Configure NGINX
COPY nginx.conf /etc/nginx/sites-available/nginx.conf
RUN unlink /etc/nginx/sites-enabled/default && \
    ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/nginx.conf && \
    chown -R www-data:www-data ./storage && \
    mkdir -p ./vendor && \
    chown -R www-data:www-data ./vendor && \
    chown -R www-data:www-data ./bootstrap/cache
