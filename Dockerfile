FROM php:7.1-apache
MAINTAINER Richard Kojedzinszky <krichy@nmdps.net>

ENV PHPIPAM_SOURCE=https://github.com/phpipam/phpipam/archive/ \
    PHPIPAM_VERSION=1.3

# Install required deb packages
RUN apt-get update && \
	apt-get install -y curl git libgmp-dev libmcrypt-dev libpng-dev libjpeg-dev libfreetype6-dev && \
	rm -rf /var/lib/apt/lists/*

# Configure apache and required PHP modules
RUN \
	docker-php-ext-install mysqli pdo_mysql gettext pcntl sockets gmp mcrypt && \
	docker-php-ext-configure gd \
		--enable-gd-native-ttf \
		--with-freetype-dir=/usr/include/freetype2 \
		--with-png-dir=/usr/include \
		--with-jpeg-dir=/usr/include && \
	docker-php-ext-install gd && \
	echo ". /etc/environment" >> /etc/apache2/envvars && \
	a2enmod rewrite
COPY php.ini /usr/local/etc/php/

# copy phpipam sources to web dir
RUN curl -L ${PHPIPAM_SOURCE}/${PHPIPAM_VERSION}.tar.gz | tar -xzf - -C /var/www/html/ --strip-components=1

# FIX upload dir permissions
RUN chown www-data:www-data app/subnets/import-subnet/upload app/admin/import-export/upload

# Use system environment variables into config.php
RUN sed \
	-e "/db.*host/s/^.*/\$db['host'] = getenv('MYSQL_ENV_MYSQL_HOST') != '' ? getenv('MYSQL_ENV_MYSQL_HOST') : 'mysql';/" \
	-e "/db.*user/s/^.*/\$db['user'] = getenv('MYSQL_ENV_MYSQL_USER') != '' ? getenv('MYSQL_ENV_MYSQL_USER') : 'phpipam';/" \
	-e "/db.*pass/s/^.*/\$db['pass'] = getenv('MYSQL_ENV_MYSQL_PASS') != '' ? getenv('MYSQL_ENV_MYSQL_PASS') : 'phpipam';/" \
	-e "/db.*name/s/^.*/\$db['name'] = getenv('MYSQL_ENV_MYSQL_NAME') != '' ? getenv('MYSQL_ENV_MYSQL_NAME') : 'phpipam';/" \
	-e "/db.*port/s/^.*/\$db['port'] = getenv('MYSQL_ENV_MYSQL_PORT') != '' ? getenv('MYSQL_ENV_MYSQL_PORT') : 3306;/" \
	/var/www/html/config.dist.php > /var/www/html/config.php

COPY phpipam-entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/phpipam-entrypoint
ENTRYPOINT ["phpipam-entrypoint"]
CMD ["apache2-foreground"]

EXPOSE 80
