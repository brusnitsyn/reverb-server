# Этап сборки фронтенда
FROM node:22 as frontend-builder

WORKDIR /app
COPY .env ./
COPY package*.json ./
COPY resources/js ./resources/js
COPY resources/css ./resources/css
COPY vite.config.js ./

RUN npm install && npm run build

# Используем официальный образ PHP
FROM php:8.3-fpm

WORKDIR /var/www/

# Установливаем зависимости
RUN apt-get update && apt-get install -y \
    build-essential \
    libonig-dev \
    libzip-dev \
    libpq-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    unzip \
    git \
    curl \
    supervisor \
    nginx

# Расширения для PHP
RUN docker-php-ext-install mbstring zip exif pcntl posix pdo_pgsql pgsql

# Redis для PHP
RUN pecl install --onlyreqdeps --force redis \
&& rm -rf /tmp/pear \
&& docker-php-ext-enable redis

RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

COPY --chown=www:www-data . /var/www
RUN ls -a /var/www/
RUN chown www-data:www-data /var/www/storage

# Копируем собранный фронтенд
COPY --from=frontend-builder /app/public /var/www/public

# Установка Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Копируем конфигурацию
COPY docker/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY docker/supervisor.conf /etc/supervisor/supervisord.conf
COPY docker/php.ini /usr/local/etc/php/conf.d/app.ini
COPY docker/nginx.conf /etc/nginx/conf.d/reverb-server.conf

# Этапы сборки
RUN composer install --no-dev --optimize-autoloader

# Настройка Nginx
RUN rm /etc/nginx/sites-enabled/default && \
    ln -s /etc/nginx/conf.d/reverb-server.conf /etc/nginx/sites-enabled/default

EXPOSE 80
# Запускаем скрипт для старта сервисов
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
