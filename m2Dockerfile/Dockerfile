#PHP IMAGE
FROM php:8.1-apache-bullseye

#SETTING UP THE SYSTEM
RUN apt-get update \
    && apt-get install -y \
    apt-utils \
    wget \
    libwebp-dev \
    libxpm-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libxslt-dev \
    libicu-dev \
    mariadb-client \
    pv \
    vim \
    nano \ 
    bash-completion \
    openssh-server \
    ssl-cert \
    msmtp \
    sudo \
    dnsutils \
    iputils-ping \
    iputils-tracepath \
    host \
    strace \
    telnet \
    unzip \
    gnupg \
    gcc \
    lsof \
    libsodium-dev \
    libzip-dev \
    parallel \
    git \
    && apt-get update \
    && apt-get clean all

#CREATE USER
ENV _USER=magento
ENV _HOME_DIRECTORY=/home/${_USER}
RUN useradd -m ${_USER} && echo "${_USER}:${_USER}" | chpasswd && chsh ${_USER} -s /bin/bash && adduser ${_USER} sudo

#PHP EXTENSIONS
RUN docker-php-ext-install -j 1 iconv soap sockets \
    && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j 1 gd bcmath pdo_mysql xsl intl zip


#COMPOSER
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer1 --1\
    && apt -qy install $PHPIZE_DEPS && mkdir /${_HOME_DIRECTORY}/.composer

#COMPOSER 2 (additional)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer2 --2

#COMPOSER link (1 is default for PHP 7.4)
RUN ln -s /usr/local/bin/composer1 /usr/local/bin/composer


#SENDMAIL
RUN echo "sendmail_path=/usr/bin/msmtp -t" >> /usr/local/etc/php/conf.d/mailcatcher.ini \
    && echo "memory_limit=4G" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "max_input_vars=10000" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "account default" >> /etc/msmtprc \
    && echo "host mailcatcher" >> /etc/msmtprc \
    && echo "port 1025" >> /etc/msmtprc \
    && echo "auto_from on" >> /etc/msmtprc

#SSH
COPY ./etc/ssh ${_HOME_DIRECTORY}/.ssh
ADD ./etc/ssh/magento2docker.pub ${_HOME_DIRECTORY}/.ssh/authorized_keys
RUN chmod -R 700 ${_HOME_DIRECTORY}/.ssh \
    && echo "    ServerAliveInterval 30" >> /etc/ssh/ssh_config \
    && echo "    TCPKeepAlive yes" >> /etc/ssh/ssh_config
COPY ./etc/ssh /root/.ssh
ADD ./etc/ssh/magento2docker.pub /root/.ssh/authorized_keys
RUN chmod -R 700 /root/.ssh \
    && echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc" >> /etc/ssh/sshd_config \
    && touch /root/.ssh/known_hosts \
    && ssh-keygen -F github.com || ssh-keyscan github.com >> /root/.ssh/known_hosts

#APACHE
RUN a2enmod ssl \
    && a2ensite default-ssl.conf \
    && a2enmod vhost_alias \
    && a2enmod proxy \
    && a2enmod rewrite \
    && chown -R ${_USER}:${_USER} /var/www/html
RUN chown -R ${_USER}:${_USER} ${_HOME_DIRECTORY}

#BASH COMPLETION
USER magento
RUN echo "source /etc/bash_completion" >> ${_HOME_DIRECTORY}/.bashrc

#MAGENTO CLI
RUN curl -sS https://accounts.magento.cloud/cli/installer | php
USER root

#TUNE ENVIRONMENT
RUN echo "Defaults    timestamp_timeout=-1" >> /etc/sudoers

#FLAG TO NOT CACHE ANYTHING FROM THIS POINT, details: https://github.com/docker/docker/issues/1996#issuecomment-185872769
ARG CACHEBUST=1

#CUSTOM CONFIGURATIONS
COPY ./etc/git/gitconfig ${_HOME_DIRECTORY}/.gitconfig
#COPY ./etc/composer/auth.json /${_HOME_DIRECTORY}/.composer/auth.json
COPY ./misc/* /usr/local/bin/
COPY ./etc/apache/envvars /etc/apache2/envvars
COPY ./etc/apache /etc/apache2/sites-enabled/
COPY ./etc/fixtures /etc/fixtures
COPY ./etc/m2install/.m2install.conf* ${_HOME_DIRECTORY}/
COPY ./etc/index.php /var/www/html/index.php

#MAGENTO TOOLS
RUN curl -o /usr/local/bin/m2install.sh https://raw.githubusercontent.com/yvoronoy/m2install/master/m2install.sh \
    && curl -o /etc/bash_completion.d/m2install-bash-completion https://raw.githubusercontent.com/yvoronoy/m2install/master/m2install-bash-completion \
    && curl -o /usr/local/bin/n98-magerun2 https://files.magerun.net/n98-magerun2.phar \
    && curl -o /etc/bash_completion.d/n98-magerun2.phar.bash https://raw.githubusercontent.com/netz98/n98-magerun2/master/res/autocompletion/bash/n98-magerun2.phar.bash \
    && curl -o /usr/local/bin/m2-convert-for-composer https://raw.githubusercontent.com/isitnikov/m2-convert-patch-for-composer-install/master/convert-for-composer.php \
    && curl -o /etc/bash_completion.d/magento2-bash-completion https://raw.githubusercontent.com/yvoronoy/magento2-bash-completion/master/magento2-bash-completion-enterprise \
    && curl -L -o /tmp/teleport.tar.gz https://github.com/gravitational/teleport/releases/download/v1.3.2/teleport-v1.3.2-linux-amd64-bin.tar.gz \
    && tar -xf /tmp/teleport.tar.gz -C /tmp/ \
    && make -C /tmp/teleport/ \
    && git ls-remote git@github.com:magento-sparta/ee-support-tools.git 2>&1 | if grep -q HEAD; then git clone git@github.com:magento-sparta/ee-support-tools.git /usr/local/src/ee-support-tools; else echo; fi \
    && if [ -d /usr/local/src/ee-support-tools ]; then ln -s /usr/local/src/ee-support-tools/cloud-teleport/cloud-teleport /usr/local/bin/cloud-teleport; else echo; fi

RUN chmod +x /usr/local/bin/*

COPY ./magento /var/www/html/magento
RUN chown -R magento:magento /var/www/html/magento
RUN cd /var/www/html/magento && composer dump-autoload