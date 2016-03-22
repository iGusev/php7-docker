FROM php:7-cli

MAINTAINER Ilya Gusev <mail@igusev.ru>

# Install composer and put binary into $PATH
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

RUN docker-php-ext-install mbstring zip
