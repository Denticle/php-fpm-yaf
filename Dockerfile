FROM php:7.2.6-fpm
ENV INSTALL_LIB_DEP="wget zip unzip"
RUN apt-get update
RUN apt-get install -y $INSTALL_LIB_DEP zlib1g-dev
RUN apt-get -yq update && \
    apt-get install -y xvfb && \
    apt-get install -y xvfb libxfont1 xfonts-encodings xfonts-utils xfonts-base xfonts-75dpi && \
    apt-get install -y wkhtmltopdf
RUN set -ex \
        && cd /opt \
        && wget https://github.com/phpredis/phpredis/archive/4.0.1.zip -O redis-4.0.1.zip \
        && unzip redis-4.0.1.zip \
        && cd phpredis-4.0.1 \
        && phpize \
        && ./configure \
        && make && make install \
        && echo "extension=redis.so" | tee /usr/local/etc/php/conf.d/redis.ini
RUN set -ex \
        && cd /opt \
        && wget https://github.com/laruence/yaf/archive/yaf-3.0.8.zip -O yaf-3.0.8.zip \
        && unzip yaf-3.0.8.zip \
        && cd yaf-yaf-3.0.8 \
        && phpize \
        && ./configure \
        && make && make install
RUN apt-get remove -y $INSTALL_LIB_DEP && apt-get clean && rm -r /var/lib/apt/lists/*
COPY SimSun.ttf /usr/share/fonts/
CMD ["php-fpm"]

