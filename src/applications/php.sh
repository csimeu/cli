#!/bin/bash

# Install a php

# https://medium.com/@daniel.bui/multiple-php-version-with-apache-on-centos-7-17078c66692c

# Reads arguments options
# function parse_php_arguments()
# {
#   # if [ $# -ne 0 ]; then
#     local TEMP=`getopt -o p:: --long data::,version::,port::,config-file:: -n "$0" -- "$@"`
    
# 	eval set -- "$TEMP"
#     # extract options and their arguments into variables.
#     while true ; do
#         case "$1" in
#             # --install-dir) INSTALL_DIR=${2:-"$INSTALL_DIR"} ; shift 2 ;;
#             # --data) data=${2%"/"} ; shift 2 ;;
#             --file-config) config_file=${2:-"$config_file"}; shift 2 ;;
#             --version) version=${2:-"$version"}; shift 2 ;;
#             --) shift ; break ;;
#             *) echo "Internal error! $1" ; exit 1 ;;
#         esac
#     done

#     shift $(expr $OPTIND - 1 )
#     _parameters=$@
    
#   # fi
# }

function php_install()
{
    set -e
    local version=
    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi


	local php_exts="fpm mysql pgsql odbc gd imap interbase intl mbstring ldap xml xmlrpc soap pear opcache json  "
	local pecl_exts="geoip memcache memcached apcu igbinary mongodb xdebug redis imagick zip   "

	local cmd=

    case `plateform` in 
        redhat)
			case $OS_VERSION in 
				8)
					if [ -z $version ]; then dnf module install php:remi-$PHP_DEFAULT_VERSION; fi
					# php_exts="fpm imap mysqlnd pgsql odbc gd  interbase intl mbstring ldap xml xmlrpc soap pear opcache json  ";
					# pecl_exts="geoip memcache memcached apcu igbinary mongodb xdebug redis imagick zip"
				;;
			esac

			version=${version/./}
			local pversion=
			if [ -n "$version" ]; then pversion=${version}-php;	fi
			#mcrypt mssql process
			for ext in $php_exts ; do  cmd+=" php$pversion-$ext"; done
			for ext in $pecl_exts ; do  cmd+=" php$pversion-pecl-$ext"; done
			# echo 
			install -y php$pversion  $cmd
            ;;
        debian)
			# https://www.digitalocean.com/community/tutorials/how-to-run-multiple-php-versions-on-one-server-using-apache-and-php-fpm-on-ubuntu-18-04
			sudo apt-get install software-properties-common -y
			sudo apt-get update -y
			# sudo add-apt-repository ppa:ondrej/php
			for ext in $php_exts ; do  cmd+=" php$version-$ext"; done
			for ext in $pecl_exts ; do  cmd+=" php$version-$ext"; done
			install -y php$version  $cmd
        ;;
    esac


	

	# version=${version/./}
	# version=${version/-php/}
	
    # local phpversion=
	# if [ -n "$version" ];
	# then 
	# 	phpversion=${version}-php
	# fi

    # sudo yum -y install php$phpversion \
	# 	php$phpversion-devel \
	# 	php$phpversion-fpm \
	# 	php$phpversion-mysql \
	# 	php$phpversion-mssql \
	# 	php$phpversion-pgsql \
	# 	php$phpversion-odbc \
	# 	php$phpversion-gd \
	# 	php$phpversion-imap \
	# 	php$phpversion- \
	# 	php$phpversion- \
	# 	php$phpversion- \
	# 	php$phpversion- \
	# 	php$phpversion- \
	# 	php$phpversion- \
	# 	php$phpversion- \
	# 	php$phpversion- \
	# 	php$phpversion- \
	# 	php$phpversion- \
	# 	php$phpversion- \
	# 	php$phpversion-pecl- \
	# 	php$phpversion-pecl- \
	# 	php$phpversion-pecl- \
	# 	php$phpversion-pecl- \
	# 	php$phpversion-pecl- \
	# 	php$phpversion-pecl- \
	# 	php$phpversion-pecl- \
	# 	php$phpversion-pecl- \
	# 	php$phpversion-pecl- \
	# 	php$phpversion-pecl- \
	# 	php$phpversion-pecl-
	
	# # Setting composer
    if [ ! -f /usr/local/bin/composer ]
    then 
	    curl -sS https://getcomposer.org/installer | php$version && sudo mv composer.phar /usr/local/bin/composer
    fi

	if [ -f /etc/httpd/conf.d/php$version-php.conf ]
    then 
	    sudo mv /etc/httpd/conf.d/php$version-php.conf /etc/httpd/conf.d/php$version-php.conf.bck
    fi

    local _BIN_="/bin"

    if [[ "$OS_VERSION" == "6" || "$(plateform)" == "debian" ]];
    then
        _BIN_="/usr/bin"
    fi

	sudo mkdir -p /var/www/cgi-bin
	if [ ! -f /var/www/cgi-bin/php$version.fcgi  ]
    then 
		sudo cat > /var/www/cgi-bin/php$version.fcgi << EOF 
#!/bin/bash 
exec $_BIN_/php$version-cgi
EOF
    fi
	
	sudo chmod 755 /var/www/cgi-bin/*.fcgi
}


# ## detect if a script is being sourced or not
# if [[ $_ == $0 ]] 
# then
# 	install_httpd "$@"
# fi
