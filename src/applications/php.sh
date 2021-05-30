#!/bin/bash

# Install a php

# https://medium.com/@daniel.bui/multiple-php-version-with-apache-on-centos-7-17078c66692c

# Reads arguments options
function parse_php_arguments()
{
  # if [ $# -ne 0 ]; then
    local TEMP=`getopt -o p:: --long data::,version::,port::,config-file:: -n "$0" -- "$@"`
    
	eval set -- "$TEMP"
    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            # --install-dir) INSTALL_DIR=${2:-"$INSTALL_DIR"} ; shift 2 ;;
            # --data) data=${2%"/"} ; shift 2 ;;
            --file-config) config_file=${2:-"$config_file"}; shift 2 ;;
            --version) version=${2:-"$version"}; shift 2 ;;
            --) shift ; break ;;
            *) echo "Internal error! $1" ; exit 1 ;;
        esac
    done

    shift $(expr $OPTIND - 1 )
    _parameters=$@
    
  # fi
}

function php_install()
{
    set -e
    local version=
    local phpversion=
    local _parameters=
    parse_php_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

	version=${version/./}
	version=${version/-php/}
	
	if [ -n "$version"];
	then 
		phpversion=${version}-php
	fi

    sudo yum -y install php$phpversion \
		php$phpversion-devel \
		php$phpversion-fpm \
		php$phpversion-mysql \
		php$phpversion-mssql \
		php$phpversion-pgsql \
		php$phpversion-odbc \
		php$phpversion-gd \
		php$phpversion-imap \
		php$phpversion-interbase \
		php$phpversion-intl \
		php$phpversion-mbstring \
		php$phpversion-mcrypt \
		php$phpversion-ldap \
		php$phpversion-xml \
		php$phpversion-xmlrpc \
		php$phpversion-soap \
		php$phpversion-pear \
		php$phpversion-process \
		php$phpversion-opcache \
		php$phpversion-pecl-geoip \
		php$phpversion-pecl-memcache \
		php$phpversion-pecl-memcached \
		php$phpversion-pecl-apcu \
		php$phpversion-pecl-apcu-devel \
		php$phpversion-pecl-igbinary \
		php$phpversion-pecl-mongodb \
		php$phpversion-pecl-redis \
		php$phpversion-pecl-xdebug \
		php$phpversion-pecl-imagick \
		php$phpversion-pecl-zip
	
	# Setting composer
    if [ ! -f /usr/local/bin/composer ]
    then 
	    curl -sS https://getcomposer.org/installer | php$version && mv composer.phar /usr/local/bin/composer
    fi

	if [ -f /etc/httpd/conf.d/php$version-php.conf ]
    then 
	    sudo mv /etc/httpd/conf.d/php$version-php.conf /etc/httpd/conf.d/php$version-php.conf.bck
    fi

    local _BIN_="/bin"

    if [[ "$(rpm -E %{rhel})" == "6"  ]];
    then
        _BIN_="/usr/bin"
    fi

	if [ ! -f /var/www/cgi-bin/php$version.fcgi  ]
    then 
		echo "#!/bin/bash \n exec $_BIN_/php$version-cgi"> /var/www/cgi-bin/php$version.fcgi
    fi
	
	sudo chmod 755 /var/www/cgi-bin/*.fcgi
}


# ## detect if a script is being sourced or not
# if [[ $_ == $0 ]] 
# then
# 	install_httpd "$@"
# fi
