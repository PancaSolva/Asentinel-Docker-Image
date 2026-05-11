FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libpq-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure GD
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg

# Install PHP extensions
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    zip \
    intl \
    gd

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

RUN rm -rf /var/www/*

RUN git clone https://github.com/PancaSolva/Asentinel.git .

RUN composer install \
    --no-dev \
    --prefer-dist \
    --no-interaction \
    --optimize-autoloader \
    -vvv

RUN chown -R www-data:www-data /var/www

RUN chmod -R 775 storage bootstrap/cache || true

EXPOSE 9000

CMD ["php-fpm"]