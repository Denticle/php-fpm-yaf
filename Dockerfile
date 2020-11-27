FROM php:7.2.6-fpm
ENV INSTALL_LIB_DEP="wget zip unzip"
# supervisor配置文件路径
ENV SUPERVISORD_CONF=/etc/supervisord.conf
# supervisor临时文件路径(日志文件、sock文件、pid文件)
ENV SUPERVISORD_TMP_CONF=/tmp/supervisor
# supervisor程序块文件路径,即是[program]块
ENV SUPERVISORD_INCLUDE_FILE=/etc/supervisordfile
# web管理界面的IP
ENV SUPERVISORD_WEB_IP=*
# web管理界面的PORT
ENV SUPERVISORD_WEB_PORT=9001
# web管理界面的账号
ENV SUPERVISORD_WEB_ACCOUNT=data
# web管理界面的密码
ENV SUPERVISORD_WEB_PASSWORD=Vdong123456.

RUN mkdir -p ${SUPERVISORD_TMP_CONF}
RUN mkdir -p ${SUPERVISORD_INCLUDE_FILE}

RUN apt-get update
RUN apt-get install -y $INSTALL_LIB_DEP zlib1g-dev
RUN apt-get -yq update && \
    apt-get install -y xvfb libxfont1 xfonts-encodings xfonts-utils xfonts-base xfonts-75dpi && \
    apt-get install -y wkhtmltopdf python-setuptools wget telinit
RUN wget --no-check-certificate https://bootstrap.pypa.io/ez_setup.py -O |python
RUN easy_install supervisor
RUN echo -e "[unix_http_server]\nfile=${SUPERVISORD_TMP_CONF}/supervisor.sock\n[inet_http_server]\nport=${SUPERVISORD_WEB_IP}:${SUPERVISORD_WEB_PORT}\nusername=${SUPERVISORD_WEB_ACCOUNT}\npassword=${SUPERVISORD_WEB_PASSWORD}\n[supervisord]\nlogfile=${SUPERVISORD_TMP_CONF}/supervisord.log\nlogfile_maxbytes=50MB\nlogfile_backups=10\nloglevel=info\npidfile=${SUPERVISORD_TMP_CONF}/supervisord.pid\nnodaemon=false\nminfds=1024\nminprocs=200\n[supervisorctl]\nserverurl=unix://${SUPERVISORD_TMP_CONF}/supervisor.sock\n[include]\nfiles = ${SUPERVISORD_INCLUDE_FILE}/*.ini" > ${SUPERVISORD_CONF}    
    
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
RUN docker-php-ext-install pdo_mysql mysqli bcmath        
RUN apt-get remove -y $INSTALL_LIB_DEP && apt-get clean && rm -r /var/lib/apt/lists/*
COPY SimSun.ttf /usr/share/fonts/
USER root
EXPOSE 22 80 9001
RUN /usr/sbin/init &
RUN /usr/sbin/telinit &
CMD ["php-fpm"]

