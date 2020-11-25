#!/bin/bash

# Install a wordpress


# Reads arguments options
function parse_wp_arguments()
{
  # if [ $# -ne 0 ]; then
    local TEMP=`getopt -o p:: --long data::,name::,version::,db-name::,db-user::,db-password::,db-host::,config-file:: -n "$0" -- "$@"`
    
	eval set -- "$TEMP"
    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            --data) data=${2%"/"} ; shift 2 ;;
            --version) version=${2:-"$version"}; shift 2 ;;
            --name) name=${2:-"$name"}; shift 2 ;;
            --db-name) DB_NAME=${2:-"$DB_NAME"}; shift 2 ;;
            --db-user) DB_USER=${2:-"$DB_USER"}; shift 2 ;;
            --db-password) DB_PASSWORD=${2:-"$DB_PASSWORD"}; shift 2 ;;
            --db-host) DB_HOST=${2:-"$DB_HOST"}; shift 2 ;;
            --db-port) DB_PORT=${2:-"$DB_PORT"}; shift 2 ;;
            --config-file) config_file=${2:-"$config_file"}; shift 2 ;;
            --) shift ; break ;;
            *) echo "Internal error! $1" ; exit 1 ;;
        esac
    done

    shift $(expr $OPTIND - 1 )
    _parameters=$@
    
  # fi
}

function wordpress_install() 
{
	set -e
  local name="wordpress"
	local version=
	local DB_NAME=
	local DB_USER=
	local DB_PASSWORD=
	local DB_HOST=localhost
	local DB_PORT=3306
	local data=
	local config_file=
    # echo $@
    local _parameters=
    parse_wp_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi
    data=${data:-"$1"}
    data=${data:-"."}
    data=${data%"/"} 

	local DIR_NAME=$data/$name
	
	wget http://wordpress.org/latest.zip
	rm -rf $DIR_NAME
	unzip -q latest.zip -d $data
	rm -f latest.zip

	if [ ! "$name" == "wordpress" ]
	then
		# echo mv $data/wordpress $data/$name
		mv -f $data/wordpress $data/$name
	fi

	# mv $_INSTALL_DIR/wordpress $_INSTALL_DIR/$_SITE_NAME
	# chown -R :$ $_INSTALL_DIR/$_SITE_NAME

	chmod -R 775 $DIR_NAME
	mkdir -p $DIR_NAME/wp-content/uploads
	# chown -R :apache $DIR_NAME/wp-content/uploads
	cp -f $DIR_NAME/wp-config-sample.php $DIR_NAME/wp-config.php

	sed -i "s/database_name_here/$DB_NAME/" $DIR_NAME/wp-config.php
	sed -i "s/username_here/$DB_USER/" $DIR_NAME/wp-config.php
	sed -i "s/password_here/$DB_PASSWORD/" $DIR_NAME/wp-config.php
	sed -i "s/localhost/$DB_HOST:$DB_PORT/" $DIR_NAME/wp-config.php
}


# if [ ! $# -eq 0 ]; 
# then
#   install_wordpress $@
# fi
