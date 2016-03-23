FROM php:7-cli

MAINTAINER Ilya Gusev <mail@igusev.ru>

# Install composer and put binary into $PATH
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer


RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd
RUN docker-php-ext-configure mysqli --with-mysqli=mysqlnd

RUN docker-php-ext-install mbstring

RUN apt-get update
RUN apt-get install -y libmcrypt-dev
RUN docker-php-ext-install mcrypt

RUN apt-get install zlib1g-dev
RUN docker-php-ext-install zip

RUN apt-get install -y git

RUN mkdir /root/.ssh/
RUN ssh-keyscan -p2200 $GITPRIVATEHOST > /root/.ssh/known_hosts

RUN  echo "    IdentityFile /root/.ssh/id_rsa" >> /etc/ssh/ssh_config
