# Usa una imagen base de PHP con Composer
FROM php:8.2.4-fpm

# Instala las dependencias necesarias
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpq-dev \
    && docker-php-ext-install pdo_pgsql

# Instala Composer globalmente
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Establece el directorio de trabajo en la aplicación Laravel
WORKDIR /var/www/html

# Copia los archivos de la aplicación Laravel al contenedor
COPY . .

# Instala las dependencias de Composer y genera el autoload
RUN composer install --optimize-autoloader --no-dev

# Cambia los permisos para que el servidor web pueda escribir en ciertos directorios
RUN chown -R www-data:www-data storage bootstrap/cache

# Expone el puerto 80 para el servidor web
EXPOSE 80

# Comando para iniciar el servidor web
CMD ["php", "artisan", "serve", "--host=0.0.0.0"]
