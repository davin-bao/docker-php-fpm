FROM php:7.1.4-fpm
MAINTAINER Davin Bao <davin.bao@gmail.com>

ENV CONFDIR /etc/php
ENV LOGDIR /var/php
ENV TIMEZONE UTC

RUN set -x \
    && addgroup -g 1982 -S www \
    && adduser -u 1982 -D -S -G www www

RUN set -xe \
    && mkdir -p $CONFDIR \
    && mkdir -p $LOGDIR \
    && mkdir -p /usr/include

#国内源
#RUN set -xe \
#    && echo https://mirror.tuna.tsinghua.edu.cn/alpine/edge/main > /etc/apk/repositories \
#    && echo http://mirrors.ustc.edu.cn/alpine/v3.3/main/ > /etc/apk/repositories \
#    && echo /etc/apk/respositories \
#    apk update

RUN apk add libmcrypt-dev && docker-php-ext-configure mcrypt --with-mcrypt && docker-php-ext-install mcrypt
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install calendar

RUN set -xe docker-php-ext-configure gd \
    --with-jpeg-dir=/usr/include --with-png-dir=/usr/include --with-webp-dir=/usr/include --with-freetype-dir=/usr/include
RUN docker-php-ext-install gd

RUN docker-php-ext-install gettext

RUN set -xe docker-php-ext-configure pdo_mysql \
    --with-pdo-mysql=mysqlnd
RUN docker-php-ext-install pdo_mysql

RUN set -xe docker-php-ext-configure mysqli \
    --with-mysqli=mysqlnd
RUN docker-php-ext-install mysqli

RUN docker-php-ext-install pcntl
RUN docker-php-ext-install reflection
RUN docker-php-ext-install shmop
RUN docker-php-ext-install SimpleXML
RUN docker-php-ext-install soap
RUN docker-php-ext-install sockets
RUN docker-php-ext-install sysvsem
RUN docker-php-ext-install wddx
RUN docker-php-ext-install xmlrpc
RUN docker-php-ext-install zip
RUN docker-php-ext-install opcache

RUN docker-php-source delete

#设置时区
ENV TIMEZONE Etc/UTC
RUN set -xe \
    && apk add --update tzdata \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone \
    apk del tzdata

COPY composer /usr/bin

RUN set -xe \
	&& chmod +x /usr/bin/composer

WORKDIR /var/www/html

VOLUME [$CONFDIR, $LOGDIR]

EXPOSE 9000

COPY php.ini /usr/local/etc/php

COPY php-fpm.conf /usr/local/etc

COPY ./php-fpm.d/* /usr/local/etc/php-fpm.d/

ADD run.sh /
RUN chmod +x /run.sh

CMD ["/run.sh"]
