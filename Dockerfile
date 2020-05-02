FROM alpine:3.11

LABEL Maintainer="Ernesto Serrano <info@ernesto.es>" \
      Description="Lightweight container with Apache & PHP-FPM 7.3 based on Alpine Linux."

# Install packages
RUN apk --no-cache add \
        php7 \
        php7-fpm \
        php7-opcache \
        php7-pecl-apcu \
        php7-mysqli \
        php7-pgsql \
        php7-json \
        php7-openssl \
        php7-curl \
        php7-zlib \
        php7-soap \
        php7-xml \
        php7-fileinfo \
        php7-phar \
        php7-intl \
        php7-dom \
        php7-xmlreader \
        php7-ctype \
        php7-session \
        php7-iconv \
        php7-tokenizer \
        php7-xmlrpc \
        php7-zip \
        php7-simplexml \
        php7-mbstring \
        php7-gd \
        apache2 \
        apache2-proxy \
        runit \
        curl \
    && rm -rf /var/cache/apk/* \
    # Make sure files/folders needed by the processes are accessable when they run under the nobody user
    && chown -R nobody.nobody /run \
    && chown -R nobody.nobody /var/log/apache2

# Add configuration files
COPY --chown=nobody config/ /
ARG MICROSCANNER_TOKEN
ENV MICROSCANNER_TOKEN=$MICROSCANNER_TOKEN
RUN apk add --no-cache ca-certificates && update-ca-certificates && \
    wget -O /microscanner https://get.aquasec.com/microscanner && \
    chmod +x /microscanner && \
    /microscanner $MICROSCANNER_TOKEN && \
    rm -rf /microscanner

# Switch to use a non-root user from here on
USER nobody

# Add application
WORKDIR /var/www/html

# Expose the port apache is reachable on
EXPOSE 8080

# Let runit start apache & php-fpm
CMD [ "/bin/docker-entrypoint.sh" ]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping

