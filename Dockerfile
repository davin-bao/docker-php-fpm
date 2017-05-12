FROM php:7.1-fpm
MAINTAINER Davin Bao <davin.bao@gmail.com>

ENV CONFDIR /etc/php
ENV LOGDIR /var/log/php
ENV TIMEZONE Etc/UTC

RUN groupadd -g 1051 www && useradd -u 1051 -g www -s /sbin/nologin www

RUN set -xe \
    && mkdir -p $CONFDIR \
    && mkdir -p $LOGDIR

# Install PHP extensions and PECL modules.
RUN buildDeps=" \
        libbz2-dev \
        libmemcached-dev \
        libmysqlclient-dev \
    mysql-client \
        libsasl2-dev \
    " \
    runtimeDeps=" \
        curl \
        git \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libicu-dev \
        libjpeg-dev \
        libmcrypt-dev \
        libmemcachedutil2 \
        libpng12-dev \
        libpq-dev \
        libxml2 \
        libxml2-dev \
    " \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y $buildDeps $runtimeDeps \
    && docker-php-ext-install  bz2 calendar iconv intl mbstring mcrypt mysqli opcache pdo_mysql pdo_pgsql pgsql zip bcmath gettext pcntl shmop sysvsem soap sockets xml xmlrpc \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && pecl install memcached redis \
    && docker-php-ext-enable memcached.so redis.so \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -r /var/lib/apt/lists/*

# 设置时区
RUN set -xe cp /usr/share/zoneinfo/Etc/UTC /etc/localtime

COPY composer /usr/bin

RUN set -xe \
    && chmod +x /usr/bin/composer \
    && composer -v

WORKDIR /var/www/html

VOLUME [$CONFDIR, $LOGDIR]

EXPOSE 9000

COPY php.ini /usr/local/etc/php

COPY php-fpm.conf /usr/local/etc

COPY ./php-fpm.d/* /usr/local/etc/php-fpm.d/

RUN set -xe \
    && sed -i 's/;error_log = log\/php-fpm.log/error_log = \/var\/log\/php-fpm\/error\.log/g' /usr/local/etc/php-fpm.conf
