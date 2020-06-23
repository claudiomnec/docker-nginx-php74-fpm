FROM ubuntu:20.04

RUN apt-get clean && apt-get -y update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nginx curl zip unzip \ 
       git software-properties-common supervisor sqlite3 libxrender1 gnupg \
       libxext6 mysql-client libssh2-1-dev vim \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends php7.4-fpm \
       php7.4-cli php7.4-gd php7.4-mysql php7.4-pgsql \
       php7.4-imap php-memcached php7.4-mbstring php7.4-xml php7.4-curl \
       php7.4-sqlite3 php7.4-zip php7.4-bcmath php7.4-soap \
       php-redis php-ssh2

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN curl -sS https://deb.nodesource.com/setup_12.x  | bash
RUN apt-get -y install nodejs

RUN update-ca-certificates;

RUN apt-get remove -y --purge software-properties-common \
        && apt-get -y autoremove \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
        && echo "daemon off;" >> /etc/nginx/nginx.conf

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

RUN mkdir /run/php

COPY default /etc/nginx/sites-available/default

COPY php-fpm.conf /etc/php/7.4/fpm/php-fpm.conf

COPY www.conf /etc/php/7.4/fpm/pool.d/www.conf

COPY php.ini /etc/php/7.4/fpm/php.ini

EXPOSE 80

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]
