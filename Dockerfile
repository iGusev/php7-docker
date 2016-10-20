FROM php:7.0.12-cli

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
ENV PHPREDIS_VERSION 3.0.0

RUN curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz \
    && tar xfz /tmp/redis.tar.gz \
    && rm -r /tmp/redis.tar.gz \
    && mkdir -p /usr/src/php/ext \
    && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
    && docker-php-ext-install redis

# Install intl
RUN apt-get install -y libicu-dev
RUN pecl install intl
RUN docker-php-ext-install intl

# Install mongodb
RUN apt-get install -y libssl-dev && \
    pecl install mongodb && \
    echo 'extension=mongodb.so' > /usr/local/etc/php/conf.d/20-mongodb.ini


# install postgresql
RUN  echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main 9.5" >> /etc/apt/sources.list.d/pgdb.list && \
    apt-get install -y wget && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update && \
    apt-get install -y postgresql-9.5

USER postgres

# Create a PostgreSQL role named ``docker`` with ``docker`` as the password and
# then create a database `docker` owned by the ``docker`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
    createdb -O docker docker

USER root

# install git
RUN apt-get install -y git

RUN mkdir /root/.ssh/
RUN  echo "    IdentityFile /root/.ssh/id_rsa" >> /etc/ssh/ssh_config
RUN  echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config

# Memcached
RUN apt-get install -yqq memcached libmemcached-dev && \
    git clone https://github.com/php-memcached-dev/php-memcached /usr/src/php/ext/memcached \
      && cd /usr/src/php/ext/memcached && git checkout -b php7 origin/php7 \
      && docker-php-ext-configure memcached \
      && docker-php-ext-install memcached 

COPY ./entrypoint.sh /
RUN /bin/bash /entrypoint.sh
