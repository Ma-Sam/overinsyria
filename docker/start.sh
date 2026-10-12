#!/bin/sh
set -eu

cd /var/www/html

if [ -z "${APP_KEY:-}" ]; then
    echo "ERROR: APP_KEY must be configured in Railway."
    exit 1
fi

PORT="${PORT:-8080}"
sed "s/PORT_PLACEHOLDER/${PORT}/g" \
    /etc/nginx/nginx.conf.template \
    > /etc/nginx/nginx.conf

mkdir -p storage/app/public storage/app/private bootstrap/cache

if [ ! -e public/storage ]; then
    php artisan storage:link
fi

php artisan migrate --force

php artisan config:cache
php artisan view:cache

php-fpm -D
nginx -g 'daemon off;'
