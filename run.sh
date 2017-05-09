#!/bin/sh

[ -f /run-pre.sh ] && /run-pre.sh

if [ ! -d $CONFDIR ] ; then
  mkdir -p $CONFDIR
fi

if [ ! -d $CONFDIR/php-fpm.d ] ; then
  mkdir -p $CONFDIR/php-fpm.d
fi

function moveConf()
{
  if [ -f $CONFDIR/$1 ] ; then
  
    if [ -f $2/$1 ] ; then
      rm -rf $2/$1
    fi

    cp -rf $CONFDIR/$1 $2/$1
    chown root:root $2/$1
  else
    cp -rf $2/$1 $CONFDIR/$1
  fi
}

$(moveConf php.ini /usr/local/etc/php);
$(moveConf fastcgi.conf /usr/local/etc);
$(moveConf php-fpm.conf /usr/local/etc);
$(moveConf php-fpm.d/www.conf /usr/local/etc);
$(moveConf php-fpm.d/docker.conf /usr/local/etc);
$(moveConf php-fpm.d/zz-docker.conf /usr/local/etc);

# start php-fpm
php-fpm
