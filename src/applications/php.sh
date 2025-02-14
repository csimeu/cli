#!/bin/bash

# Install a php

# https://medium.com/@daniel.bui/multiple-php-version-with-apache-on-centos-7-17078c66692c

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

	local php_exts="fpm pgsql odbc gd intl mbstring ldap xml soap pear opcache json fileinfo simplexml xmlreader xmlwriter zip zlib"
	local pecl_exts="apcu xdebug "
	# local php_exts=" mysql  imap interbase xmlrpc"

	local cmd=
	# for ext in $php_exts ; do  phps+=" php$pversion-$ext"; done
	# for ext in $pecl_exts ; do  phps+=" php$pversion-pecl-$ext"; done

    case `platform` in 
        alpine)
			# https://www.cyberciti.biz/faq/how-to-install-php-7-fpm-on-alpine-linux/
			php_exts="$php_exts mysqlnd mysqli phar pdo pdo_mysql pdo_pgsql pdo_sqlite pdo_odbc pdo_dblib ctype curl iconv dom tokenizer dev exif common"
			pecl_exts="$pecl_exts memcache memcached uploadprogress igbinary mongodb redis imagick uuid"
			version=${version%.*}
			case ${version/./} in 
				5|7) php_exts="$php_exts xmlrpc " 
				;;
			esac
		;;
        redhat)
			install -y ImageMagick ImageMagick-devel
			if [ "1" == "$IS_DEFAULT" ] ; then
				PHP_DEFAULT_VERSION=${version:-$PHP_DEFAULT_VERSION}
				version=
				echo "---> Set default php version '$PHP_DEFAULT_VERSION'"
				case $OS_VERSION in 
					6|7)
						execute yum-config-manager --enable remi-php${PHP_DEFAULT_VERSION/./};
					;;
					*)
						execute yum module reset -y php || true;
						execute dnf module enable -y php:remi-${PHP_DEFAULT_VERSION} || true;
						# execute yum module enable -y php:${PHP_DEFAULT_VERSION} || true;

					;;
				esac
			fi

			case $OS_VERSION in 
				6|7)
					php_exts="$php_exts mysql imap interbase xmlrpc"
					pecl_exts="$pecl_exts geoip memcache memcached  igbinary mongodb redis imagick zip "
				;;
				*)
					php_exts="$php_exts mysqlnd "
					pecl_exts="$pecl_exts zip redis  "
				;;
			esac

			version=${version/./}
            ;;
        debian|ubuntu)
			# https://www.digitalocean.com/community/tutorials/how-to-run-multiple-php-versions-on-one-server-using-apache-and-php-fpm-on-ubuntu-18-04
			sudo apt-get install lsb-release apt-transport-https ca-certificates -y 
			# sudo apt-get install software-properties-common lsb-release apt-transport-https ca-certificates -y 

			sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
			echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
			sudo apt-get update -y
			# sudo add-apt-repository ppa:ondrej/php
			# for ext in $php_exts ; do  cmd+=" php$version-$ext"; done
			# for ext in $pecl_exts ; do  cmd+=" php$version-$ext"; done
			# install php$version  $cmd
			
			php_exts="fpm cli mysql pgsql odbc gd imap interbase intl mbstring ldap xml xmlrpc soap pdo curl bcmath opcache zip sqlite3 imagick xdebug apcu redis"
			pecl_exts=
			case ${version/./} in 
				5|7) php_exts="$php_exts json  " 
				;;
			esac

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


    if [[ $(getent passwd apache)  ]];
    then
		case `platform` in 
			alpine) install php$version-apache2 ;;
			debian|ubuntu)
				install libapache2-mod-php$version
			;;
		esac

		if [ -f /etc/php.ini ]; then 
			sudo chown apache:apache -R /etc/php.ini; 
			sudo chmod g+w -R /etc/php.ini;
		fi
		
		if [ -d /etc/php$version ]; then 
			sudo chown apache:apache -R /etc/php$version ; 
			sudo chmod g+w -R /etc/php$version;
		fi
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
	
	if [[ ! -f /usr/bin/php && -f /usr/bin/php$version ]]
    then 
	    sudo ln -s /usr/bin/php$version /usr/bin/php
    fi

	if [[ ! ( -f /etc/php.ini || -L /etc/php.ini ) && -f /etc/php$version/php.ini ]]
    then 
	    sudo ln -s /etc/php$version/php.ini /etc/php.ini
    fi

	# # Setting composer
    if [ ! -f /usr/bin/composer ]
    then
		curl -sS https://getcomposer.org/installer |sudo  php -- --install-dir=/usr/bin --filename=composer
		# case `platform` in 
		# 	alpine) install composer ;;
		# 	*) curl -sS https://getcomposer.org/installer | php$version && sudo mv composer.phar /usr/bin/composer
		# 	;;
    	# esac
    fi

    if [ ! -f /usr/bin/symfony ]
    then 
		case `platform` in 
			redhat)
				curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.rpm.sh' | sudo -E bash
				install symfony-cli
			;;

        	debian|ubuntu)
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

    if [[ "$OS_VERSION" == "6" || "$(platform)" == "debian" || "$(platform)" == "ubuntu" ]];
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


if [ -f /etc/ImageMagick-6/policy.xml ]; then
	# 1. Sauvegarde du fichier original
	sudo cp /etc/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy.xml.backup

	# 2. Supprimer les restrictions de formats PDF
	sudo sed -i '/<policy domain="coder" rights="none" pattern="PDF"/d' /etc/ImageMagick-6/policy.xml

	# 3. Supprimer toutes les autres restrictions
	sudo sed -i '/<policy domain="coder" rights="none" pattern=/d' /etc/ImageMagick-6/policy.xml
fi

# ## detect if a script is being sourced or not
# if [[ $_ == $0 ]] 
# then
# 	install_httpd "$@"
# fi
