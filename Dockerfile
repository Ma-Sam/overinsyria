FROM php:8.4-fpm

# Install system dependencies + Node.js
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev libicu-dev supervisor nginx \
    ca-certificates gnupg \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Disable default php-fpm pool and use our own
RUN rm -f /usr/local/etc/php-fpm.d/*.conf
COPY docker/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

# Nginx config
COPY docker/nginx.conf /etc/nginx/sites-available/default
RUN rm -f /etc/nginx/sites-enabled/default && ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Supervisor config
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /var/www
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --prefer-source

# Install Node dependencies and build assets
RUN npm install && npm run build

# Permissions
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache /var/www/public/build

EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]