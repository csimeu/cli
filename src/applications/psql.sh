#!/bin/bash

# Reads arguments options
function parse_postgresql_arguments()
{
  # if [ $# -ne 0 ]; then
    local TEMP=`getopt -o p:: --long data::,version::,port::,config-file:: -n "$0" -- "$@"`
    
	eval set -- "$TEMP"
    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            --data) data=${2%"/"} ; shift 2 ;;
            --file-config) config_file=${2:-"$config_file"}; shift 2 ;;
            --version) _version=${2:-"$_version"}; shift 2 ;;
            --port) port=${2:-"$port"}; shift 2 ;;
            --users-config) users_config=${2:-"$users_config"}; shift 2 ;;
            # --db-name) DB_NAME=${2:-"$DB_NAME"}; shift 2 ;;
            # --db-user) DB_USER=${2:-"$DB_USER"}; shift 2 ;;
            # --db-password) DB_PASSWORD=${2:-"$DB_PASSWORD"}; shift 2 ;;
            # --db-host) DB_HOST=${2:-"$DB_HOST"}; shift 2 ;;
            # --port) port=${2:-"$port"}; shift 2 ;;
            --) shift ; break ;;
            *) echo "Internal error! $1" ; exit 1 ;;
        esac
    done

    shift $(expr $OPTIND - 1 )
    _parameters=$@
    
  # fi
}

function psql_install() 
{
    set -e
    local _version="${1:-"11"}"
    local _parameters=
    parse_postgresql_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    # Install postgresql 11  https://www.postgresql.org/download/linux/redhat/
    sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
    yum install -y postgresql$_version  postgresql$_version-libs postgresql$_version-server postgresql$_version-devel postgis25_$_version \
    systemctl enable postgresql-$_version 

}

psql_init(){
    local version=11
    local data=


    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi


    local data=${data:-"/var/lib/pgsql/${version}/data"}

    if [[ ( ! -d $data ) || ( ! "$(ls -A $data)" ) ]]; then
        echo "Init postgresql $version"
        /usr/pgsql-${version}/bin/postgresql-${version}-setup initdb
        # systemctl restart postgresql-${version} 
        # systemctl restart postgresql-${version} 

        if ! grep '0.0.0.0/0' $data/pg_hba.conf ; then
            echo 'host      all     all     0.0.0.0/0 md5' >> $data/pg_hba.conf
        fi
    fi
}

