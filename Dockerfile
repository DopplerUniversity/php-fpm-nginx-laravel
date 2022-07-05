FROM php:7-fpm

ENV TZ="America/Los_Angeles"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install git unzip gnupg -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Doppler CLI
RUN curl -Ls --tlsv1.2 --proto "=https" --retry 3 https://cli.doppler.com/install.sh | sh

WORKDIR /usr/src/app

COPY --chown=www-data:www-data laravel /usr/src/app

RUN composer install --no-scripts --no-interaction

CMD ["./bin/php-fpm-start.sh", "php-fpm"]