FROM php:7.2.6-fpm
MAINTAINER Davin Bao <davin.bao@gmail.com>

ENV TIMEZONE Etc/UTC

RUN groupadd -g 1982 www && useradd -u 1982 -g www -s /sbin/nologin www

RUN usermod -u 1982 www 
RUN groupmod -g 1982 www

RUN apt-get update && apt-get install -y \
    bash \
    sudo \
    libmcrypt-dev \
    libicu-dev \
    mysql-client \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxml2 \
    libxml2-dev \
    libpcre3-dev \
    libc-client-dev \
    git \
    vim \
    net-tools \
    procps \
    telnet \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libssl-dev \
    libkrb5-dev \
    poppler-utils \
    htop
        
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install imap

RUN docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-install iconv \
    && docker-php-ext-install intl \
    && docker-php-ext-install opcache \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install gettext \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install soap \
    && docker-php-ext-install sockets \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install shmop \
    && docker-php-ext-install sysvsem \
    && docker-php-ext-install xml \
    && docker-php-ext-install xmlrpc \
    && docker-php-ext-install zip \
    && docker-php-source delete
    
# 设置时区
RUN set -xe cp /usr/share/zoneinfo/Etc/UTC /etc/localtime
# 关闭 core 文件生成
RUN set -xe echo 'ulimit -c 0' >> /etc/profile

COPY composer /usr/bin

RUN set -xe \
    && chmod +x /usr/bin/composer
	
RUN php -r "copy('https://phar.phpunit.de/phpunit.phar','/tmp/phpunit.phar');"
RUN chmod +x /tmp/phpunit.phar
RUN mv /tmp/phpunit.phar /usr/local/bin/phpunit

COPY php.ini /usr/local/etc/php

COPY php-fpm.conf /usr/local/etc

COPY ./php-fpm.d/* /usr/local/etc/php-fpm.d/

WORKDIR /var/www/html

VOLUME ['/usr/local/etc/']

EXPOSE 9000

CMD ["php-fpm", "-c", "/usr/local/etc/php.ini", "-y", "/usr/local/etc/php-fpm.conf"]
