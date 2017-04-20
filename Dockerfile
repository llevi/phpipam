FROM php:5.6-apache
MAINTAINER Richard Kojedzinszky <krichy@nmdps.net>

ENV PHPIPAM_SOURCE https://github.com/phpipam/phpipam/archive/
ENV PHPIPAM_VERSION master

# Install required deb packages
RUN apt-get update && \
	apt-get install -y git php-pear php5-curl php5-mysql php5-json php5-gmp php5-mcrypt php5-ldap libgmp-dev libmcrypt-dev && \
	rm -rf /var/lib/apt/lists/*

# Configure apache and required PHP modules
RUN docker-php-ext-configure mysqli --with-mysqli=mysqlnd && \
	docker-php-ext-install mysqli && \
	docker-php-ext-install pdo_mysql && \
	docker-php-ext-install gettext && \
	docker-php-ext-install pcntl && \
	docker-php-ext-install sockets && \
	ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h && \
	docker-php-ext-configure gmp --with-gmp=/usr/include/x86_64-linux-gnu && \
	docker-php-ext-install gmp && \
	docker-php-ext-install mcrypt && \
	echo ". /etc/environment" >> /etc/apache2/envvars && \
	a2enmod rewrite

COPY php.ini /usr/local/etc/php/

# copy phpipam sources to web dir
ADD ${PHPIPAM_SOURCE}/${PHPIPAM_VERSION}.tar.gz /tmp/
RUN	tar -xzf /tmp/${PHPIPAM_VERSION}.tar.gz -C /var/www/html/ --strip-components=1

# Use system environment variables into config.php
RUN sed \
	-e "/db.*host/s/^.*/\$db['host'] = getenv('MYSQL_ENV_MYSQL_HOST') != '' ? getenv('MYSQL_ENV_MYSQL_HOST') : 'mysql';/" \
	-e "/db.*user/s/^.*/\$db['user'] = getenv('MYSQL_ENV_MYSQL_USER') != '' ? getenv('MYSQL_ENV_MYSQL_USER') : 'phpipam';/" \
	-e "/db.*pass/s/^.*/\$db['pass'] = getenv('MYSQL_ENV_MYSQL_PASS') != '' ? getenv('MYSQL_ENV_MYSQL_PASS') : 'phpipam';/" \
	-e "/db.*name/s/^.*/\$db['name'] = getenv('MYSQL_ENV_MYSQL_NAME') != '' ? getenv('MYSQL_ENV_MYSQL_NAME') : 'phpipam';/" \
	-e "/db.*port/s/^.*/\$db['port'] = getenv('MYSQL_ENV_MYSQL_PORT') != '' ? getenv('MYSQL_ENV_MYSQL_PORT') : 3306;/" \
	/var/www/html/config.dist.php > /var/www/html/config.php

EXPOSE 80

