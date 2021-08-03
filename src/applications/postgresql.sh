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
                echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | sudo tee  /etc/apt/sources.list.d/pgdg.list
                sudo apt -y update
            fi
            ;;
        redhat)
            if [[ ! -f /etc/yum.repos.d/pgdg-redhat-all.repo ]]; then
                install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-$OS_VERSION-x86_64/pgdg-redhat-repo-latest.noarch.rpm
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
                # sudo dnf -qy module disable postgresql
                echo ">> dnf config-manager --set-enabled powertools"
                if [ "$EUID" -eq 0 ]; then dnf config-manager --set-enabled powertools; else sudo dnf config-manager --set-enabled powertools; fi
                echo ">> install -y dnf-plugins-core gdal-devel "
                install -y dnf-plugins-core gdal-devel 
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
                # https://serverfault.com/questions/1049330/error-conflicting-requests-in-centos-8-package-installation
                echo ">> dnf -qy module disable postgresql"
                if [ "$EUID" -eq 0 ]; then
                    dnf -qy module disable postgresql; 
                else 
                    sudo dnf -qy module disable postgresql; 
                fi
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

postgresql_createuser(){
    local version=11
    local data=

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    cd /tmp
	if [[ -n "$DB_USER" ]] ; then
		EXISTS_USER="$(sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'")"
		if [[ -z "$EXISTS_USER" ]]; then
			sudo -u postgres psql --command "CREATE USER $DB_USER WITH SUPERUSER ;"
		fi
		# TODO: Change user password if user already exist
		if [[ -n "$DB_PASSWORD" ]]; then
			sudo -u postgres psql --command "ALTER USER $DB_USER with PASSWORD '$DB_PASSWORD';"
		fi
	fi
}

postgresql_createdb(){
    # local version=11
    # local data=

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi
    
    cd /tmp
    
    if [[ -z "$DB_NAME" ]]; then
        echo "===>> ERROR: --db-name={DB_NAME} required"
        exit 0;
    fi
    if [[ -z "$DB_USER" ]]; then
        echo "===>> ERROR: --db-user={DB_OWNER} required"
        exit 0;
    fi

	EXISTS_DB="$(sudo -u postgres psql -tAc "SELECT datname FROM pg_catalog.pg_database WHERE datname='$DB_NAME'")"
	if [[ -z "$EXISTS_DB" ]]; then
		sudo -u postgres createdb -O $DB_USER $DB_NAME
	fi
	sudo -u postgres psql $DB_NAME --command "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
}

postgresql_setup(){
    local version=11
    local data=

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    local data=${data:-"/var/lib/pgsql/${version}/data"}

    if [[ ( ! -d $data ) || ( ! "$(ls -A $data)" ) ]]; then
        echo "Init postgresql $version"
        /usr/pgsql-${version}/bin/postgresql-${version}-setup initdb
    fi

    if ! grep '0.0.0.0/0' $data/pg_hba.conf ; then
        echo 'host      all     all     0.0.0.0/0 md5' >> $data/pg_hba.conf
    fi
    sed -i -e 's/ident$/md5/g' $data/pg_hba.conf

	systemctl enable postgresql-${version} --now
	systemctl restart postgresql-${version}
	sleep 2
	# cd /tmp

	# echo "DB_USER=$DB_USER DB_PASSWORD=$DB_PASSWORD DB_NAME=$DB_NAME" 
	# if [[ -n "$DB_USER" ]] ; then
	# 	EXISTS_USER="$(sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'")"
	# 	if [[ -z "$EXISTS_USER" ]]; then
	# 		sudo -u postgres psql --command "CREATE USER $DB_USER WITH SUPERUSER ;"
	# 	fi
	# 	# TODO: Change user password if user already exist
	# 	if [[ -n "$DB_PASSWORD" ]]; then
	# 		sudo -u postgres psql --command "ALTER USER $DB_USER with PASSWORD '$DB_PASSWORD';"
	# 	fi
	# fi
	# EXISTS_DB="$(sudo -u postgres psql -tAc "SELECT datname FROM pg_catalog.pg_database WHERE datname='$DB_NAME'")"
	# if [[ -z "$EXISTS_DB" ]]; then
	# 	sudo -u postgres createdb -O $DB_USER $DB_NAME
	# fi
	# sudo -u postgres psql $DB_NAME --command "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
}


postgresql_execfile()
{
    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

	local file=$1
    if [[ -n "$file" ]]; then
        echo "===>> ERROR: SQL's file is required as first argument"
        exit 0;
    fi

    if [[ -z "$DB_NAME" ]]; then
        echo "===>> ERROR: --db-name={DB_NAME} required"
        exit 0;
    fi
    cat $file | psql "postgresql://$DB_USER:$DB_PASSWORD@${DB_HOST:-localhost}/$DB_NAME"
}

