#!/bin/bash

# Install a php

# https://medium.com/@daniel.bui/multiple-php-version-with-apache-on-centos-7-17078c66692c



function php_install()
{
    set -e
    local version="${1}"

    sudo yum -y install php$version \
		php$version-devel \
		php$version-fpm \
		php$version-mysql \
		php$version-mssql \
		php$version-pgsql \
		php$version-odbc \
		php$version-gd \
		php$version-imap \
		php$version-interbase \
		php$version-intl \
		php$version-mbstring \
		php$version-mcrypt \
		php$version-ldap \
		php$version-xml \
		php$version-xmlrpc \
		php$version-soap \
		php$version-pear \
		php$version-process \
		php$version-opcache \
		php$version-pecl-geoip \
		php$version-pecl-memcache \
		php$version-pecl-memcached \
		php$version-pecl-apcu \
		php$version-pecl-apcu-devel \
		php$version-pecl-igbinary \
		php$version-pecl-mongodb \
		php$version-pecl-redis \
		php$version-pecl-xdebug \
		php$version-pecl-imagick \
		php$version-pecl-zip
	
	# Setting composer
    if [ ! -f /usr/local/bin/composer ]
    then 
	    curl -sS https://getcomposer.org/installer | php$version && mv composer.phar /usr/local/bin/composer
    fi

	if [ -f /etc/httpd/conf.d/php$version-php.conf ]
    then 
	    mv /etc/httpd/conf.d/php$version-php.conf /etc/httpd/conf.d/php$version-php.conf.bck
    fi

    local _BIN_="/bin"

    if [[ "$(rpm -E %{rhel})" == "6"  ]];
    then
        _BIN_="/usr/bin"
    fi

	if [ ! -f /var/www/cgi-bin/php$version.fcgi  ]
    then 
		echo "#!/bin/bash \n exec $_BIN_/php74-cgi"> /var/www/cgi-bin/php$version.fcgi
    fi
	
	sudo chmod 755 /var/www/cgi-bin/*.fcgi
}


# ## detect if a script is being sourced or not
# if [[ $_ == $0 ]] 
# then
# 	install_httpd "$@"
# fi
