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

function php_remove()
{
    set -e
    local version=
    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi
	
	local php_exts="fpm mysql pgsql odbc gd imap interbase intl mbstring ldap xml xmlrpc soap pear opcache json  "
	local pecl_exts="geoip memcache memcached apcu igbinary mongodb xdebug redis imagick zip   "
	local cmd=
	version=${version/./}
	if [ "1" == "$IS_DEFAULT" ]; then
		version=
	fi

	if has_command php$version ; then 
		for ext in $php_exts ; do  cmd+=" php$version-$ext"; done
		for ext in $pecl_exts ; do  cmd+=" php$version-pecl-$ext"; done
		remove -y php$version $cmd
	fi
}

function php_install()
{
	# php_remove $@
    set -e
    local version=
    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

	local php_exts="fpm pgsql odbc gd intl mbstring ldap xml xmlrpc soap pear opcache json  "
	local pecl_exts="apcu xdebug "
	# local php_exts=" mysql  imap interbase xmlrpc"

	local cmd=
	# for ext in $php_exts ; do  phps+=" php$pversion-$ext"; done
	# for ext in $pecl_exts ; do  phps+=" php$pversion-pecl-$ext"; done

    case `plateform` in 
        alpine)
			# https://www.cyberciti.biz/faq/how-to-install-php-7-fpm-on-alpine-linux/
			version=${version%.*}
		;;
        redhat)
			if [ "1" == "$IS_DEFAULT" ] ; then
				PHP_DEFAULT_VERSION=${version:-$PHP_DEFAULT_VERSION}
				version=
				echo "---> Set default php version '$PHP_DEFAULT_VERSION'"
				case $OS_VERSION in 
					6|7)
						execute yum-config-manager --enable remi-php${PHP_DEFAULT_VERSION/./};
						php_exts="$php_exts mysql imap interbase "
						pecl_exts="$pecl_exts geoip memcache memcached  igbinary mongodb redis imagick zip "
					;;
					*)
						execute yum module reset -y php;
						execute yum module enable -y php:${PHP_DEFAULT_VERSION};
						# execute yum module install -y php:-${PHP_DEFAULT_VERSION};
						php_exts="$php_exts mysqlnd  "
						pecl_exts="$php_exts zip  "
					;;
				esac
			fi

			# if [ -z $version ]; then 
			# 	echo "PHP_DEFAULT_VERSION=$PHP_DEFAULT_VERSION"
			# 	case $OS_VERSION in 
			# 		8)
			# 			if [ "$EUID" -ne 0 ]; then sudo yum module install -y php:remi-$PHP_DEFAULT_VERSION; else yum module install -y php:remi-$PHP_DEFAULT_VERSION; fi
			# 			# php_exts="fpm imap mysqlnd pgsql odbc gd  interbase intl mbstring ldap xml xmlrpc soap pear opcache json  ";
			# 			# pecl_exts="geoip memcache memcached apcu igbinary mongodb xdebug redis imagick zip"
			# 		;;
			# 		6|7)
			# 			if [ "$EUID" -ne 0 ]; then sudo yum-config-manager --enable remi-php${PHP_DEFAULT_VERSION/./}; else yum-config-manager --enable remi-php${PHP_DEFAULT_VERSION/./}; fi
			# 			# php_exts="fpm imap mysqlnd pgsql odbc gd  interbase intl mbstring ldap xml xmlrpc soap pear opcache json  ";
			# 			# pecl_exts="geoip memcache memcached apcu igbinary mongodb xdebug redis imagick zip"
			# 		;;
			# 	esac
			# fi 

			version=${version/./}
			# local pversion=
			# if [ -n "$version" ]; then pversion=${version}-php;	fi
			#mcrypt mssql process
            ;;
        debian)
			# https://www.digitalocean.com/community/tutorials/how-to-run-multiple-php-versions-on-one-server-using-apache-and-php-fpm-on-ubuntu-18-04
			sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
			echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
			sudo apt-get install software-properties-common lsb-release apt-transport-https ca-certificates -y 
			sudo apt-get update -y
			# sudo add-apt-repository ppa:ondrej/php
			# for ext in $php_exts ; do  cmd+=" php$version-$ext"; done
			# for ext in $pecl_exts ; do  cmd+=" php$version-$ext"; done
			# install php$version  $cmd
			
			php_exts="fpm cli mysql pgsql odbc gd imap interbase intl mbstring ldap xml xmlrpc soap pdo curl bcmath json opcache json  "
			pecl_exts=
        ;;
    esac

	for ext in $php_exts ; do  cmd+=" php$version-$ext"; done
	for ext in $pecl_exts ; do  cmd+=" php$version-pecl-$ext"; done
	echo "Install: php$version $cmd"
	
	install php$version $cmd

	if [ -f /etc/httpd/conf.modules.d/00-mpm.conf ]; then
		sudo sed -i -e "s/^LoadModule mpm_event_module/#LoadModule mpm_event_module/" /etc/httpd/conf.modules.d/00-mpm.conf
		sudo sed -i -e "s/^#LoadModule mpm_prefork_module/LoadModule mpm_prefork_module/" /etc/httpd/conf.modules.d/00-mpm.conf
	fi

	# echo "Install: php$version php$version-* "
	# install -y php$version php$version-* 

	

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
    if [ ! -f /usr/bin/composer ]
    then
		case `plateform` in 
			alpine) install composer ;;
			*) curl -sS https://getcomposer.org/installer | php$version && sudo mv composer.phar /usr/bin/composer
			;;
    	esac
    fi

    if [ ! -f /usr/bin/symfony ]
    then 
		case `plateform` in 
			redhat)
				curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.rpm.sh' | sudo -E bash
				install symfony-cli
			;;

        	debian)
				curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | sudo -E bash
				install symfony-cli
			;;

        	alpine)
				sudo apk add --no-cache bash
				curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.alpine.sh' | sudo -E bash
				sudo apk add symfony-cli
			;;
    	esac
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
		sudo tee /var/www/cgi-bin/php$version.fcgi << EOF > /dev/null
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
