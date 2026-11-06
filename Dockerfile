# Build the actual app.
# Base image is set here directly: since Supervisor 2026.04 build.yaml is legacy
# and BUILD_FROM is no longer provided by default.
FROM ghcr.io/hassio-addons/debian-base:9.5.2

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


ENV MATOMO_VERSION=5.14.2
RUN mkdir -p /var/www/html \
    && rm /var/www/html/index.nginx-debian.html \
    && chown www-data:www-data /var/www/html \
    && curl -fsSL -o /tmp/matomo.tar.gz "https://builds.matomo.org/matomo-${MATOMO_VERSION}.tar.gz" \
    && tar -xzf /tmp/matomo.tar.gz -C /var/www/html --strip-components=1 \
    && rm /tmp/matomo.tar.gz \
    && chown -R www-data:www-data /var/www/html

# Copy root filesystem
COPY rootfs /
RUN chmod +x /etc/s6-overlay/s6-rc.d/init-mariadb/run \
  && chmod +x /etc/s6-overlay/s6-rc.d/init-nginx/run \
  && chmod +x /etc/s6-overlay/s6-rc.d/init-matomo-data/run

#COPY php.ini
COPY php.ini /usr/local/etc/php/conf.d/php-matomo.ini

# Build arguments (only BUILD_ARCH and BUILD_VERSION are still provided by Supervisor)
ARG BUILD_ARCH
ARG BUILD_VERSION

LABEL \
    io.hass.name="Matomo" \
    io.hass.description="Matomo analytics with embedded MariaDB" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="app" \
    io.hass.version=${BUILD_VERSION}