FROM php:7.1.4-fpm-alpine
MAINTAINER Davin Bao <davin.bao@gmail.com>

ENV CONFDIR /etc/php
ENV LOGDIR /var/php
ENV TIMEZONE UTC

RUN set -x \
    && addgroup -g 1982 -S www \
    && adduser -u 1982 -D -S -G www www

RUN set -xe \
    && mkdir -p $CONFDIR \
    && mkdir -p $LOGDIR

#国内源
RUN set -xe \
    && echo https://mirror.tuna.tsinghua.edu.cn/alpine/edge/main > /etc/apk/repositories \
    && echo http://mirrors.ustc.edu.cn/alpine/v3.3/main/ > /etc/apk/repositories \
    && echo /etc/apk/respositories \
    apk update
#设置时区
ENV TIMEZONE Etc/UTC
RUN set -xe \
    && apk add --update tzdata \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone \
    apk del tzdata

# RUN set -xe apk add libmcrypt-dev && docker-php-ext-configure mcrypt --with-mcrypt && docker-php-ext-install mcrypt

RUN set -xe docker-php-ext-configure gd \
    --with-jpeg-dir=/usr/include --with-png-dir=/usr/include --with-webp-dir=/usr/include --with-freetype-dir=/usr/include

RUN set -xe docker-php-ext-configure pdo_mysql \
    --with-pdo-mysql=mysqlnd

RUN set -xe docker-php-ext-configure mysqli \
    --with-mysqli=mysqlnd

RUN set -xe \
    && docker-php-ext-install bcmath \
    calendar \
    gd \
    gettext \
    pdo_mysql \
    mysqli \
    pcntl \
    reflection \
    shmop \
    SimpleXML \
    soap \
    sockets \
    sysvsem \
    wddx \
    xmlrpc \
    zip \
    opcache

RUN set -xe docker-php-source delete

COPY composer /usr/bin

RUN set -xe \
	&& composer -v

WORKDIR /var/www/html

VOLUME [$CONFDIR, $LOGDIR]

EXPOSE 9000

COPY php.ini /usr/local/etc/php

COPY php-fpm.conf /usr/local/etc

COPY ./php-fpm.d/* /usr/local/etc/php-fpm.d

RUN set -xe \
    && sed -i 's/;error_log = log\/php-fpm.log/error_log = $LOGDIR\/php-fpm\/error\.log/g' /usr/local/etc/php-fpm.conf

ADD run.sh /
RUN chmod +x /run.sh

CMD ["/run.sh"]
