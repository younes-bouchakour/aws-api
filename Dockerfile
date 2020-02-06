FROM composer:1.9.1 as vendors

COPY ./composer.* /app/

RUN composer install --ignore-platform-reqs --no-ansi --no-interaction --prefer-dist --no-dev --no-progress \
  --no-suggest --optimize-autoloader --no-scripts --quiet

FROM php:7.4.2-fpm-alpine3.11 as php

RUN apk add --update --no-cache acl=2.2.53-r0 \
  icu-dev=64.2-r0 \
  postgresql-dev=12.1-r0 \
  && docker-php-ext-install intl pdo pdo_pgsql pgsql

COPY ./ /srv/api
COPY --from=vendors /app/vendor /srv/api/vendor

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && echo 'opcache.interned_strings_buffer=16' > "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo 'opcache.memory_consumption=256' > "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo 'opcache.max_accelerated_files=20000' >> "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo 'opcache.validate_timestamps=0' >> "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo 'realpath_cache_size=4096K' >> "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo 'realpath_cache_ttl=600' >> "$PHP_INI_DIR/conf.d/opcache.ini" \
    && sed -i 's|variables_order = "GPCS"|variables_order = "EGPCS"|' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/expose_php = On/expose_php = Off/g' "$PHP_INI_DIR/php.ini"

COPY .docker/php/entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

WORKDIR /srv/api

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]

FROM nginx:1.17.8-alpine as nginx

COPY .docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=php /srv/api/public /srv/api/public

WORKDIR /srv/api/public