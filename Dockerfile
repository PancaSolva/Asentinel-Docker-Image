FROM php:8.2-cli

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    zip \
    unzip \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY composer.json composer.lock /var/www/


COPY . /var/www

RUN composer install --prefer-dist --no-interaction --optimize-autoloader

RUN chown -R www-data:www-data /var/www

CMD ["php-fpm"]