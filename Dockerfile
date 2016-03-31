FROM php:7-cli

MAINTAINER Ilya Gusev <mail@igusev.ru>

# Install composer and put binary into $PATH
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer


RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd
RUN docker-php-ext-configure mysqli --with-mysqli=mysqlnd

RUN docker-php-ext-install mbstring
RUN docker-php-ext-install bcmath
RUN curl -O https://xdebug.org/files/xdebug-2.4.0.tgz
RUN tar -xzf xdebug-2.4.0.tgz \
    && cd xdebug-2.4.0/ \
    && phpize \
    && ./configure --enable-xdebug \
    && make \
    && echo 'zend_extension="/xdebug-2.4.0/modules/xdebug.so"' > /usr/local/etc/php/conf.d/20-xdebug.ini


RUN apt-get update
RUN apt-get install -y libmcrypt-dev
RUN docker-php-ext-install mcrypt

RUN apt-get install zlib1g-dev
RUN docker-php-ext-install zip
ENV PHPREDIS_VERSION php7

RUN curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz \
    && tar xfz /tmp/redis.tar.gz \
    && rm -r /tmp/redis.tar.gz \
    && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
    && docker-php-ext-install redis


RUN apt-get install -y git

RUN mkdir /root/.ssh/

RUN  echo "    IdentityFile /root/.ssh/id_rsa" >> /etc/ssh/ssh_config
RUN  echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config

COPY ./entrypoint.sh /
RUN /bin/bash /entrypoint.sh
