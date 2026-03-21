ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base:9.2.0

# Build the actual app.
FROM ${BUILD_FROM}

ENV PHP_MEMORY_LIMIT=256M

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Add MariaDB + Nginx + Deps
RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        mariadb-server \
        nginx \
        curl \
        php8.4-fpm \
        php8.4-mysql \
        php8.4-cli \
        php8.4-gd \
        php8.4-curl \
        php8.4-xml \
        php8.4-mbstring \
        php8.4-zip \
    && apt-get clean \
    && rm -f -r \
        /etc/nginx \
    \
    && mkdir -p /var/log/nginx \
    && touch /var/log/nginx/error.log


ENV MATOMO_VERSION=5.8.0
RUN mkdir -p /var/www/html \
    && chown www-data:www-data /var/www/html \
    && curl -fsSL -o /tmp/matomo.tar.gz "https://builds.matomo.org/matomo-${MATOMO_VERSION}.tar.gz" \
    && tar -xzf /tmp/matomo.tar.gz -C /var/www/html --strip-components=1 \
    && rm /tmp/matomo.tar.gz \
    && chown -R www-data:www-data /var/www/html

# Copy root filesystem
COPY rootfs /
RUN chmod +x /etc/s6-overlay/s6-rc.d/init-mariadb/run \
  && chmod +x /etc/s6-overlay/s6-rc.d/init-nginx/run

#COPY php.ini
COPY php.ini /usr/local/etc/php/conf.d/php-matomo.ini

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_VERSION

LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION}