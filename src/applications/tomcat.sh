#!/bin/bash

# Install tomcat


# Reads arguments options
function parse_tomcat_arguments()
{
    # if [ $# -ne 0 ]; then
    local TEMP=`getopt -o p:: --long tomcat-config::,users-config::,config-file:: -n "$0" -- "$@"`
      
    eval set -- "$TEMP"
    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            --data) data=${2%"/"} ; shift 2 ;;
            --file-config) config_file=${2:-"$config_file"}; shift 2 ;;
            # --tomcat-config) tomcat_config=${2:-"$tomcat_config"}; shift 2 ;;
            --users-config) users_config=${2:-"$users_config"}; shift 2 ;;
            # --db-name) DB_NAME=${2:-"$DB_NAME"}; shift 2 ;;
            # --db-user) DB_USER=${2:-"$DB_USER"}; shift 2 ;;
            # --db-password) DB_PASSWORD=${2:-"$DB_PASSWORD"}; shift 2 ;;
            # --db-host) DB_HOST=${2:-"$DB_HOST"}; shift 2 ;;
            # --db-port) DB_PORT=${2:-"$DB_PORT"}; shift 2 ;;
            --) shift ; break ;;
            *) echo "Internal error! $1" ; exit 1 ;;
        esac
    done

    shift $(expr $OPTIND - 1 )
    _parameters=$@
    
  # fi
}

function tomcat_install() 
{
	set -e
	local users_config=
	local file_config=
    # echo $@
    local _parameters=
    parse_tomcat_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi
    # data=${data:-"$1"}
    # data=${data:-"."}
    # data=${data%"/"} 

	if [[ -n "$file_config" && ! -f $file_config ]]
	then
    echo "File not found $file_config" 
    exit 1
	fi

	if [[ -n "$users_config" && ! -f $users_config ]]
	then
    echo "File not found $users_config" 
    exit 1
	fi

    sudo yum install -y tomcat tomcat-webapps tomcat-admin-webapps
  
	if [[ -n "$file_config" ]]
	then
    sudo rm -f /etc/tomcat/tomcat.conf.old
    sudo mv /etc/tomcat/tomcat.conf /etc/tomcat/tomcat.conf.old
    sudo mv  $file_config /etc/tomcat/tomcat.conf
	fi
  
	if [[ -n "$users_config" ]]
	then
    sudo rm -f /etc/tomcat/tomcat-users.xml.old
    sudo mv /etc/tomcat/tomcat-users.xml /etc/tomcat/tomcat-users.xml.old
    sudo mv  $users_config /etc/tomcat/tomcat-users.xml
	fi
}


# if [ ! $# -eq 0 ]; 
# then
#   install_tomcat $@
# fi
