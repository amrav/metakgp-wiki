FROM php:7.4-fpm-buster

RUN apt-get -qq update && apt-get -qq install -y \
      git wget unzip

WORKDIR /tmp
RUN wget -q https://releases.wikimedia.org/mediawiki/1.34/mediawiki-1.34.0.tar.gz \
      && tar -xzf mediawiki-1.34.0.tar.gz \
      && mkdir -p /srv \
      && mv /tmp/mediawiki-1.34.0 /srv/mediawiki

COPY install_extensions.sh post_install.sh /tmp/
RUN /tmp/install_extensions.sh

COPY LocalSettings.php robots.txt install_composer.sh composer.local.json /srv/mediawiki/

WORKDIR /srv/mediawiki

COPY extensions/ extensions/
RUN ./install_composer.sh \
      && php composer.phar update --no-dev --optimize-autoloader --no-suggest --no-progress

COPY assets/ resources/assets/

COPY gmconvert.sh /opt/

RUN mkdir -p /srv/static/images && rm -rf images && ln -s /srv/static/images images
RUN mkdir -p images/temp

ENTRYPOINT /tmp/post_install.sh
