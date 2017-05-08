# docker-php-fpm
docker php-fpm 7.1.4

## example 

create docker-compose.yml like this:

``` yml
version: "3"

services:
    redis:
      image: redis:3
      networks:
        - dms
      deploy:
        mode: global
        resources:
          # Hard limit - Docker does not allow to allocate more
          limits:
            cpus: '0.25'
            memory: 512M
          # Soft limit - Docker makes best effort to return to it
          reservations:
            cpus: '0.25'
            memory: 256M
        # service restart policy
        restart_policy:
            condition: on-failure
            
    php:
      image: davinbao/php-fpm:latest
      ports:
        - "9000:9000"
      networks:
        - dms
      volumes:
        - /var/www:/home/www
      deploy:
        mode: global
        resources:
          # Hard limit - Docker does not allow to allocate more
          limits:
            cpus: '0.25'
            memory: 512M
          # Soft limit - Docker makes best effort to return to it
          reservations:
            cpus: '0.25'
            memory: 256M
        # service restart policy
        restart_policy:
            condition: on-failure
            
    nginx:
      image: davinbao/nginx:latest
      volumes:
        - /var/www:/home/www
      ports:
        - "80:80"
      networks:
        - dms
      depends_on:
        - php
        - redis
      deploy:
        mode: global
        restart_policy:
            condition: on-failure
networks:
    dms:
      driver: bridge
```
