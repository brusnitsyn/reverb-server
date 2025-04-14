# Используем официальный образ PHP с Nginx (например, для Laravel)
FROM laravelsail/php82-composer:latest

# Устанавливаем зависимости
RUN apt-get update && apt-get install -y \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Копируем код проекта
COPY . /var/www/html
WORKDIR /var/www/html

# Устанавливаем зависимости Laravel
RUN composer install --optimize-autoloader --no-dev

# Копируем конфигурацию Supervisor для Reverb
COPY ./docker/supervisor/reverb.conf /etc/supervisor/conf.d/reverb.conf

# Запускаем скрипт для старта сервисов
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
