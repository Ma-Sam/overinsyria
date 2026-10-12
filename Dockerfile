FROM php:8.4-fpm

RUN apt-get update && apt-get install -y git curl zip unzip libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libxml2-dev libzip-dev libicu-dev supervisor nginx && docker-php-ext-configure gd --with-freetype --with-jpeg && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl

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

RUN composer install --no-dev --optimize-autoloader --prefer-source

RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]