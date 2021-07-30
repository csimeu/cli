#!/bin/bash


# Reads arguments options
function parse_postgresql_arguments()
{
  # if [ $# -ne 0 ]; then
    local long="data::,version::,postgis-version::,postgresql-version::,port::,config-file::"
    # echo "long = $long"
    local TEMP=`getopt -o p:: --long $long -n "$0" -- "$@"`
    
	eval set -- "$TEMP"
    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            --data) data=${2%"/"} ; shift 2 ;;
            --file-config) config_file=${2:-"$config_file"}; shift 2 ;;
            --version) _version=${2:-"$_version"}; shift 2 ;;
            --postgis-version) _postgis_version=${2}; shift 2 ;;
            --postgis) _postgis_version=${2}; shift 2 ;;
            --postgresql-version) _postgresql_version=${2:-$_postgresql_version}; shift 2 ;;
            --postgresql) _postgresql_version=${2}; shift 2 ;;
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

postgresql_add_repolist() {
    case `plateform` in 
        debian)
            if [[ ! -f /etc/apt/sources.list.d/pgdg.list ]]; then
                cd /tmp
                wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
                echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
                sudo apt -y update
            fi
            ;;
        redhat)
            if [[ ! -f /etc/yum.repos.d/pgdg-redhat-all.repo ]]; then
                sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-$OS_VERSION-x86_64/pgdg-redhat-repo-latest.noarch.rpm
            fi
        ;;
    esac
}


function postgis_install() 
{
    set -e
    local _postgresql_version=
    local _postgis_version=$POSTGIS_DEFAULT_VERSION
    local _parameters=
    parse_postgresql_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    postgresql_add_repolist

    case `plateform` in 
        debian)
            install -y postgresql-$_postgresql_version-postgis-$_postgis_version
            ;;
        redhat)
            if [ '8' == "$OS_VERSION" ]; then 
                # https://serverfault.com/questions/1049330/error-conflicting-requests-in-centos-8-package-installation
                sudo dnf -qy module disable postgresql
                install -y dnf-plugins-core
                install -y gdal-devel
            fi
            install -y postgis${_postgis_version//./}_$_postgresql_version # postgis24_11
        ;;
    esac

}

function postgresql_install() 
{
    set -e
    local _postgresql_version=$POSTGRESQL_DEFAULT_VERSION
    local _postgis_version=
    local _parameters=
    parse_postgresql_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    postgresql_add_repolist

    case `plateform` in 
        debian)
            install -y postgresql-${_postgresql_version} postgresql-client-${_postgresql_version} postgresql-$_postgresql_version-pglogical pgbouncer
            ;;
        redhat)
            if [ '8' == "$OS_VERSION" ]; then 
                # sudo dnf config-manager --set-enabled PowerTools
                # sudo yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
                sudo dnf -qy module disable postgresql
            fi
            install -y postgresql$_postgresql_version  postgresql$_postgresql_version-libs postgresql$_postgresql_version-server
            
        ;;
    esac
    
    if [[ -n "$_postgis_version" ]]
    then 
        # echo "postgis_install --postgresql-version=$_postgresql_version --postgis-version=$_postgis_version"
        postgis_install --postgresql-version=$_postgresql_version --postgis-version=$_postgis_version
    fi
}

postgresql_init(){
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

