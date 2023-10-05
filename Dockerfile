FROM php:7.3.4-apache

#Update stretch repositories
RUN sed -i s/deb.debian.org/archive.debian.org/g /etc/apt/sources.list
RUN sed -i 's|security.debian.org|archive.debian.org/|g' /etc/apt/sources.list
RUN sed -i '/stretch-updates/d' /etc/apt/sources.list

# Get dependencies for PrestaShop
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       vim wget \
       dialog \
       git \
       libxml2-dev \
       libicu-dev \
       zlib1g-dev \
        g++ \
	&& rm -rf /var/lib/apt/lists/*

# Install Mcrypt
RUN apt-get update \
    && apt-get install -y libmcrypt-dev \
    && pecl install mcrypt \
    && docker-php-ext-enable mcrypt

# Install Mbstring
RUN docker-php-ext-configure mbstring --enable-mbstring && \
    docker-php-ext-install mbstring

# Install CURL
RUN apt-get update && apt-get install -y curl

# Install DOM
RUN docker-php-ext-install dom

# Install Fileinfo
RUN docker-php-ext-install fileinfo

# Install GD
RUN apt-get update \
	&& apt-get install -y \
		libfreetype6-dev \
		libpng-dev \
		libjpeg-dev \
	&& docker-php-ext-configure gd \
		--with-freetype-dir=/usr/include/ \
		--with-jpeg-dir=/usr/include/ \
		--with-png-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) \
		gd \
	&& apt-get purge -y \
		libfreetype6-dev \
		libpng-dev \
		libjpeg-dev

# Install iconv
RUN docker-php-ext-install iconv

# Install Intl
RUN docker-php-ext-configure intl \
  && docker-php-ext-install intl

# Install JSON
RUN docker-php-ext-install json

# Install Mbstring
RUN docker-php-ext-configure mbstring --enable-mbstring
RUN docker-php-ext-install mbstring

# Install ZIP
RUN apt-get install -y zip libzip-dev \
  && docker-php-ext-configure zip --with-libzip \
  && docker-php-ext-install zip

# Install OpenSSL
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install --fix-missing libcurl3 \
    libcurl3-openssl-dev \
    openssl && \
    rm -rf /var/lib/apt/lists/*

# Install Postgre PDO
RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql

# Install SimpleXML
RUN docker-php-ext-install simplexml

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
        && mv composer.phar /usr/local/bin/ \
        && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Install Bcmath
RUN docker-php-ext-configure bcmath --enable-bcmath
RUN docker-php-ext-install bcmath

# Install Soap
RUN docker-php-ext-configure soap --enable-soap
RUN docker-php-ext-install soap

# instal gettext & tokenizer
RUN docker-php-ext-install gettext
RUN docker-php-ext-install tokenizer

# Install Opcache
RUN docker-php-ext-install opcache
RUN docker-php-ext-enable opcache

# Copy opcache configration
# COPY ./docker/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY ./assets/php/php.ini /usr/local/etc/php/conf.d/php.ini

# XDebug
RUN pecl install xdebug-2.7.0
RUN docker-php-ext-enable xdebug

# Xmlrpc
RUN docker-php-ext-install xmlrpc
RUN docker-php-ext-install xmlwriter 

#Install SSL Cert
# RUN apt-get update
# RUN apt-get install -y ssl-cert

# Setup Apache2 mod_ssl
# RUN a2enmod ssl
RUN a2enmod rewrite
RUN a2enmod headers
# Setup Apache2 HTTPS env
# RUN mkdir -p /etc/apache2/ssl
# COPY ./assets/ssl/cert.pem /etc/apache2/ssl/cert.pem
# COPY ./assets/ssl/key.pem /etc/apache2/ssl/key.pem
COPY ./assets/apache/default.conf /etc/apache2/sites-enabled/000-default.conf

# RUN update-ca-certificates

EXPOSE 80
EXPOSE 443

# Clean up
RUN apt-get remove -y git && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Apache configuration
RUN a2enmod rewrite
RUN chown -R www-data:www-data /var/www/html/
RUN usermod -u 1000 www-data