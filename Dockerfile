ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base:9.2.0

# Get prebuilt containers from Matomo
FROM matomo:5.8.0-fpm-alpine AS matomo

# Build the actual app.
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Get the Matomo from official images
COPY --from=matomo /var/www/html /var/www/html

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

# Copy root filesystem
COPY rootfs /
RUN chmod +x /etc/s6-overlay/s6-rc.d/init-mariadb/run

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