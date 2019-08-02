FROM phusion/baseimage
MAINTAINER gvkazare
ENV REFRESHED_AT 2019-06-23

# based on dgraziotin/lamp
# MAINTAINER Daniel Graziotin <daniel@ineed.coffee>

ENV DOCKER_USER_ID 501 
ENV DOCKER_USER_GID 20

ENV BOOT2DOCKER_ID 1000
ENV BOOT2DOCKER_GID 50

# Tweaks to give Apache/PHP write permissions to the app
RUN usermod -u ${BOOT2DOCKER_ID} www-data && \
    usermod -G staff www-data && \
    useradd -r mysql && \
    usermod -G staff mysql

RUN groupmod -g $(($BOOT2DOCKER_GID + 10000)) $(getent group $BOOT2DOCKER_GID | cut -d: -f1)
RUN groupmod -g ${BOOT2DOCKER_GID} staff

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN add-apt-repository -y ppa:ondrej/php && \
  add-apt-repository ppa:openjdk-r/ppa && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y install openjdk-11-jdk nano mc alien python3-pip python-virtualenv supervisor wget git apache2 php-xdebug libapache2-mod-php5.6 mysql-server php5.6 php5.6-mysql pwgen php5.6-apc php5.6-mcrypt php5.6-gd php5.6-xml php5.6-mbstring php5.6-gettext zip unzip php5.6-zip php5.6-dev php5.6-cli php-pear && \
  apt-get -y autoremove && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
  pip3 install --upgrade pip && \
  pip install pymysql pycurl paramiko textfsm tabulate pika cx_Oracle crontab

# Update CLI PHP to use 5.6
RUN ln -sfn /usr/bin/php5.6 /etc/alternatives/php

# Install OCI8
RUN mkdir -p /opt/oracle && cd /opt/oracle

RUN wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/FnqCMt5WsXOEfg -O /opt/oracle/instantclient-basic-linux.x64-12.2.0.1.0.zip
RUN wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/ZjgHZxJ7frL7kw -O /opt/oracle/instantclient-jdbc-linux.x64-12.2.0.1.0.zip
RUN wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/mPH2GwBlsBUv9Q -O /opt/oracle/instantclient-odbc-linux.x64-12.2.0.1.0-2.zip
RUN wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/7Gi116pkWeZQvA -O /opt/oracle/instantclient-sdk-linux.x64-12.2.0.1.0.zip
RUN wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/O2q2sa9PEu7xgg -O /opt/oracle/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip
RUN wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/x_0ZkHIjIFAzKg -O /opt/oracle/instantclient-tools-linux.x64-12.2.0.1.0.zip

RUN chmod 777 /opt/oracle/*

#ADD supporting_files/zip/instantclient-basic-linux.x64-12.2.0.1.0.zip /opt/oracle/instantclient-basic-linux.x64-12.2.0.1.0.zip
#ADD supporting_files/zip/instantclient-jdbc-linux.x64-12.2.0.1.0.zip /opt/oracle/instantclient-jdbc-linux.x64-12.2.0.1.0.zip
#ADD supporting_files/zip/instantclient-odbc-linux.x64-12.2.0.1.0-2.zip /opt/oracle/instantclient-odbc-linux.x64-12.2.0.1.0-2.zip
#ADD supporting_files/zip/instantclient-sdk-linux.x64-12.2.0.1.0.zip /opt/oracle/instantclient-sdk-linux.x64-12.2.0.1.0.zip
#ADD supporting_files/zip/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip /opt/oracle/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip
#ADD supporting_files/zip/instantclient-tools-linux.x64-12.2.0.1.0.zip /opt/oracle/instantclient-tools-linux.x64-12.2.0.1.0.zip 

RUN unzip /opt/oracle/instantclient-basic*.zip -d /opt/oracle && unzip /opt/oracle/instantclient-jdbc*.zip -d /opt/oracle && unzip /opt/oracle/instantclient-odbc*.zip -d /opt/oracle && unzip /opt/oracle/instantclient-sdk*.zip -d /opt/oracle && unzip /opt/oracle/instantclient-sqlplus*.zip -d /opt/oracle &&unzip /opt/oracle/instantclient-tools*.zip -d /opt/oracle
RUN mv /opt/oracle/instantclient_12_2 /opt/oracle/instantclient

RUN ln -s /opt/oracle/instantclient/libclntsh.so.* /opt/oracle/instantclient/libclntsh.so
RUN ln -s /opt/oracle/instantclient/libocci.so.* /opt/oracle/instantclient/libocci.so
RUN ln -s /opt/oracle/instantclient/ /opt/oracle/instantclient/lib 

RUN mkdir -p /opt/oracle/include/oracle/12.2 && ln -s ../../../sdk/include /opt/oracle/include/oracle/12.2/client
RUN mkdir -p /opt/oracle/lib/oracle/12.2/client && ln -s ../../../ /opt/oracle/lib/oracle/12.2/client/lib

RUN echo /opt/oracle/instantclient/ | tee -a /etc/ld.so.conf.d/oracle.conf
RUN ldconfig && ln -s /usr/include/php5 /usr/include/php

RUN yes 'instantclient,/opt/oracle/instantclient' | pecl install oci8-1.4.10
RUN echo "; configuration for php oci8 module" | tee /etc/php/5.6/apache2/conf.d/oci8.ini
RUN echo extension=oci8.so | tee -a /etc/php/5.6/apache2/conf.d/oci8.ini
RUN chmod 777 /etc/php/5.6/apache2/conf.d/oci8.ini

#RUN /etc/init.d/apache2 restart

# Install PDO_OCI
ADD supporting_files/pdo_oci/pdo_oci.so /usr/lib/php/20131226/pdo_oci.so

RUN echo "; configuration for php PDO_OCI module" | tee /etc/php/5.6/apache2/conf.d/pdo_oci.ini
RUN echo extension=pdo_oci.so | tee -a /etc/php/5.6/apache2/conf.d/pdo_oci.ini
RUN chmod 777 /etc/php/5.6/apache2/conf.d/pdo_oci.ini

#RUN /etc/init.d/apache2 restart

# needed for phpMyAdmin
RUN phpenmod mcrypt

# Add image configuration and scripts
ADD supporting_files/start-apache2.sh /start-apache2.sh
ADD supporting_files/start-mysqld.sh /start-mysqld.sh
ADD supporting_files/run.sh /run.sh
RUN chmod 755 /*.sh

ADD supporting_files/supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supporting_files/supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Set PHP timezones to Europe/London
RUN sed -i "s/;date.timezone =/date.timezone = Europe\/London/g" /etc/php/5.6/apache2/php.ini
RUN sed -i "s/;date.timezone =/date.timezone = Europe\/London/g" /etc/php/5.6/cli/php.ini

# Remove pre-installed database
RUN rm -rf /var/lib/mysql

# Add MySQL utils
ADD supporting_files/create_mysql_users.sh /create_mysql_users.sh
RUN chmod 755 /*.sh

# Add phpmyadmin
ENV PHPMYADMIN_VERSION=4.6.4
RUN wget -O /tmp/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz
RUN tar xfvz /tmp/phpmyadmin.tar.gz -C /var/www
RUN ln -s /var/www/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages /var/www/phpmyadmin
RUN mv /var/www/phpmyadmin/config.sample.inc.php /var/www/phpmyadmin/config.inc.php

# Add composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

ENV MYSQL_PASS:-$(pwgen -s 12 1)
# config to enable .htaccess
ADD supporting_files/apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Configure /app folder with sample app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html
ADD app/ /app

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for the app and MySql
VOLUME  ["/etc/mysql", "/var/lib/mysql", "/app" ]

EXPOSE 22 80 443 3306
CMD ["/run.sh"]
