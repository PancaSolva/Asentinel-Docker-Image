FROM php:8.3-fpm

RUN apt-get update && apt-get install -y \
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
    nodejs \
    npm \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg

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

# Download repo as zip and extract — no git required
RUN curl -L https://github.com/PancaSolva/Asentinel/archive/refs/heads/main.zip -o app.zip \
    && unzip app.zip \
    && mv Asentinel-main/* . \
    && mv Asentinel-main/.* . 2>/dev/null || true \
    && rm -rf Asentinel-main app.zip

RUN composer install \
    --no-dev \
    --prefer-dist \
    --no-interaction \
    --optimize-autoloader

RUN npm install && npm run build

RUN chown -R www-data:www-data /var/www
RUN chmod -R 775 storage bootstrap/cache

EXPOSE 9000

CMD ["php-fpm"]