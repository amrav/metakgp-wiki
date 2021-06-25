FROM php:7.4-fpm-buster
RUN apt-get -qq update && apt-get -qq install -y \
            build-essential \
            git-core \
            gnupg2 \
            graphicsmagick \
            libfreetype6-dev \
            libicu-dev \
            libjpeg62-turbo-dev \
            libpng-dev \
            wget \
      && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
      && docker-php-ext-install -j$(nproc) gd intl mysqli opcache \
      && pecl install apcu \
      && docker-php-ext-enable apcu \
      && pear install Numbers_Words-beta \
      && apt-get purge

ENV TZ=Asia/Kolkata
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY php.ini /usr/local/etc/php/

# New Relic
RUN echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list \
      && wget -q -O- https://download.newrelic.com/548C16BF.gpg | apt-key add - \
      && apt-get update \
      && apt-get -qq install -y newrelic-php5 \
      && NR_INSTALL_SILENT=1 newrelic-install install \
      && sed -i \
          -e "s/newrelic.appname =.*/newrelic.appname = \"Metakgp Wiki\"/" \
          -e "s/newrelic.license =.*/newrelic.license = \${NEWRELIC_LICENSE}/" \
          -e "s/;newrelic.framework =.*/newrelic.framework = \"mediawiki\"/" \
          /usr/local/etc/php/conf.d/newrelic.ini

RUN mkdir -p /var/log/mediawiki \
      && touch /var/log/mediawiki/debug.log \
      && chown -R www-data:www-data /var/log/mediawiki
VOLUME /var/log
