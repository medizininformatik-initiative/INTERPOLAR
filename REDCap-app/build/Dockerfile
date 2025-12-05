# "php:apache" siehe https://hub.docker.com/r/library/php/
FROM php:8.4-apache-trixie

LABEL maintainer "Sebastian Stäubert <sebastian.staeubert@imise.uni-leipzig.de>"

# Packages Utils
RUN apt-get update && apt-get install -y -q \
	apt-utils \
	vim less \
	wget curl

# Packages fuer den Mailversand
RUN apt-get update && apt-get install -y -q \
	msmtp msmtp-mta \
	mailutils

# PHP-Erweiterungen iconv, gd, zip, mysqli, imagick installieren
RUN apt-get install -y \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
		libzip-dev \
		libmagickwand-dev 

# Erweiterung für PHP: iconv
RUN docker-php-ext-configure iconv \
    && docker-php-ext-install -j$(nproc) iconv

# Erweiterung für PHP: gd
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# PECL Erweiterung für PHP: zip
RUN pecl install zip \
    && docker-php-ext-enable zip

# PECL Erweiterung für PHP: imagick
RUN pecl install imagick \
    && docker-php-ext-enable imagick
COPY config/policy.xml /etc/ImageMagick-6

# Erweiterung für PHP: mysqli
RUN docker-php-ext-install mysqli

# Konfigurationen für Mail und PHP in das IMAGE kopieren (könnte auch via Volume gemacht werden)
COPY config/msmtprc /etc/msmtprc
RUN chown root:msmtp /etc/msmtprc \
    && chmod 640 /etc/msmtprc
COPY config/mail.rc /etc/mail.rc
COPY config/php.ini /usr/local/etc/php/

# Mount Volumes instead...
#RUN mkdir /var/www/html/redcap
#COPY redcap /var/www/html/redcap
#RUN mkdir /var/www/html/redcapdocs
#COPY redcapdocs /var/www/html/redcapdocs
#RUN chown -R www-data:www-data /var/www/html

# Cleanup
RUN apt-get clean && \
	apt-get autoremove -yq && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
