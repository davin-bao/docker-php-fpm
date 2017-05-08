#!/bin/sh

[ -f /run-pre.sh ] && /run-pre.sh

if [ ! -d $CONFDIR ] ; then
  mkdir -p $CONFDIR
fi

if [ ! -d $CONFDIR/php-fpm.d ] ; then
  mkdir -p $CONFDIR/php-fpm.d
fi

if [ -f $CONFDIR/php-fpm.conf ] ; then
  cp $CONFDIR/php-fpm.conf /usr/local/etc/php-fpm.conf
  chown root:root /usr/local/etc/php-fpm.conf
else
  cp /usr/local/etc/php-fpm.conf $CONFDIR/php-fpm.conf
fi

if [ -f $CONFDIR/php-fpm.d/www.conf ] ; then
  cp $CONFDIR/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf
  chown root:root /usr/local/etc/php-fpm.d/www.conf
else
  cp /usr/local/etc/php-fpm.d/www.conf $CONFDIR/php-fpm.d/www.conf
fi

if [ -f $CONFDIR/php-fpm.d/docker.conf ] ; then
  cp $CONFDIR/php-fpm.d/docker.conf /usr/local/etc/php-fpm.d/docker.conf
  chown root:root /usr/local/etc/php-fpm.d/docker.conf
else
  cp /usr/local/etc/php-fpm.d/docker.conf $CONFDIR/php-fpm.d/docker.conf
fi

if [ -f $CONFDIR/php-fpm.d/zz-docker.conf ] ; then
  cp $CONFDIR/php-fpm.d/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
  chown root:root /usr/local/etc/php-fpm.d/zz-docker.conf
else
  cp /usr/local/etc/php-fpm.d/zz-docker.conf $CONFDIR/php-fpm.d/zz-docker.conf
fi


# start php-fpm
php-fpm
