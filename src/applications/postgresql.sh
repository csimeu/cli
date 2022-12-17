#!/bin/bash



postgresql_add_repolist() {
    case `plateform_name` in 
        debian|ubuntu)
            if [[ ! -f /etc/apt/sources.list.d/pgdg.list ]]; then
                cd /tmp
                install gnupg2 lsb-release
                wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
                echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | sudo tee  /etc/apt/sources.list.d/pgdg.list
                sudo apt -y update
            fi
            ;;
        fedora)
            if [[ ! -f /etc/yum.repos.d/pgdg-redhat-all.repo ]]; then
                install https://download.postgresql.org/pub/repos/yum/reporpms/F-$OS_VERSION-x86_64/pgdg-redhat-repo-latest.noarch.rpm
            fi
            ;;
        redhat)
            if [[ ! -f /etc/yum.repos.d/pgdg-redhat-all.repo ]]; then
                # dnf install https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
                install https://download.postgresql.org/pub/repos/yum/reporpms/EL-$OS_VERSION-x86_64/pgdg-redhat-repo-latest.noarch.rpm
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
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    postgresql_add_repolist
    _postgresql_version=${postgresql_version:-$_postgresql_version}
    _postgis_version=${postgis_version:-$_postgis_version}

    case `plateform` in 
        alpine)
            install postgis ;;
        debian|ubuntu)
            install postgresql-$_postgresql_version-postgis-$_postgis_version
            ;;
        redhat)
            if [ '8' == "$OS_VERSION" ]; then 
                # https://serverfault.com/questions/1049330/error-conflicting-requests-in-centos-8-package-installation
                # sudo dnf -qy module disable postgresql
                echo ">> dnf config-manager --set-enabled powertools"
                if [ "$EUID" -eq 0 ]; then dnf config-manager --set-enabled powertools; else sudo dnf config-manager --set-enabled powertools; fi
                echo ">> install dnf-plugins-core gdal-devel "
                install dnf-plugins-core gdal-devel 
            fi
            install postgis${_postgis_version//./}_$_postgresql_version # postgis24_11
        ;;
    esac

}

function postgresql_install() 
{
    set -e
    local _postgresql_version=$POSTGRESQL_DEFAULT_VERSION
    local _postgis_version=
    local _parameters=
    local version=14
    local data=
    local log=
    local port=5432
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    postgresql_add_repolist
    
    _postgresql_version=${version:-$_postgresql_version}
    _postgis_version=${postgis_version:-$_postgis_version}
    # data=${data:-"/var/lib/pgsql/$_postgresql_version/data"}
    data=${data:-"/var/lib/postgresql/$_postgresql_version/data"}
    log=${log:-"/var/log/postgresql-$_postgresql_version.log"}

    # echo "PGDATA=/var/lib/pgsql/$_postgresql_version/data"
    # PG_BIN="/usr/pgsql-${_postgresql_version}/bin"


    case `plateform` in 
        alpine)
            install postgresql$_postgresql_version  postgresql$_postgresql_version-openrc postgresql$_postgresql_version-contrib
            sudo mkdir -p /run/postgresql
            sudo chown postgres:postgres /run/postgresql
        ;;
        debian|ubuntu)
            # data="/var/lib/postgresql/${_postgresql_version}/data"
            # PG_BIN="/usr/lib/postgresql/${_postgresql_version}/bin"
            install postgresql-${_postgresql_version} postgresql-client-${_postgresql_version} postgresql-$_postgresql_version-pglogical pgbouncer
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
            install postgresql$_postgresql_version  postgresql$_postgresql_version-libs postgresql$_postgresql_version-server postgresql-contrib-$_postgresql_version
        ;;
    esac
    
    postgresql_init --version=$_postgresql_version --data=$data

    if [[ -n "$_postgis_version" ]]
    then 
        # echo "postgis_install --postgresql-version=$_postgresql_version --postgis-version=$_postgis_version"
        postgis_install --postgresql-version=$_postgresql_version --postgis-version=$_postgis_version
    fi
    
    # if [[ -n "$ADMIN_USER" && $(getent passwd $ADMIN_USER)  ]]; then 
    #     sudo usermod -aG postgres $ADMIN_USER;    
    # fi
}

postgresql_create_user(){

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    cd /tmp
    DB_USER=${DB_USER:-"$user"}
    DB_PASSWORD=${DB_PASSWORD:-"$password"}

	if [[ -n "$DB_USER" ]] ; then
        if [ "$(id -u -n)" == "postgres" ]; then
            EXISTS_USER="$(psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'")"
            if [[ -z "$EXISTS_USER" ]]; then
                psql --command "CREATE USER $DB_USER WITH SUPERUSER ;"
            fi
            # Change user password if user already exist
            if [[ -n "$DB_PASSWORD" ]]; then
                psql --command "ALTER USER $DB_USER with PASSWORD '$DB_PASSWORD';"
            fi
        else
            EXISTS_USER="$(sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'")"
            if [[ -z "$EXISTS_USER" ]]; then
                sudo -u postgres psql --command "CREATE USER $DB_USER WITH SUPERUSER ;"
            fi
            # Change user password if user already exist
            if [[ -n "$DB_PASSWORD" ]]; then
                sudo -u postgres psql --command "ALTER USER $DB_USER with PASSWORD '$DB_PASSWORD';"
            fi
        fi
	fi
}

postgresql_create_db(){
    # local version=11
    # local data=

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi
    
    cd /tmp
    DB_NAME=${DB_NAME:-"$name"}
    DB_USER=${DB_USER:-"$user"}
    
    if [[ -z "$DB_NAME" ]]; then
        echo "===>> ERROR: required --db-name={DB_NAME} or --name={DB_NAME} "
        exit 0;
    fi
    if [[ -z "$DB_USER" ]]; then
        echo "===>> ERROR: --db-user={DB_USER} required"
        exit 0;
    fi

    if [ "$(id -u -n)" == "postgres" ]; then
            EXISTS_DB="$(psql -tAc "SELECT datname FROM pg_catalog.pg_database WHERE datname='$DB_NAME'")"
        if [[ -z "$EXISTS_DB" ]]; then
            createdb -O $DB_USER $DB_NAME
        fi

        psql $DB_NAME --command "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
    else
        EXISTS_DB="$(sudo -u postgres psql -tAc "SELECT datname FROM pg_catalog.pg_database WHERE datname='$DB_NAME'")"
        if [[ -z "$EXISTS_DB" ]]; then
            sudo -u postgres createdb -O $DB_USER $DB_NAME
        fi

        sudo -u postgres psql $DB_NAME --command "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
    fi
}

postgresql_start(){
    local version=$POSTGRESQL_VERSION
    local port=${POSTGRESQL_PORT:-"5432"}
    local data=
    local log=

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    data=${data:-"/var/lib/postgresql/${version}/data"}
    log=${log:-"/var/log/postgresql-${version}.log"}

    # if [[ ! -f "$log" ]]; then
    #     sudo touch $log
    #     sudo chown postgres:postgres $log
    # fi

    # postgresql_ctl -D $data -o '-p 5443' restart
    # postgresql_ctl -D $data -l $log -o "\"-p $port\"" restart

    # local cmd=pg_ctl

    # if [ -d /usr/lib/postgresql/${version}/bin ]; then
    #     cmd=/usr/lib/postgresql/${version}/bin/pg_ctl
    # elif [ -f /usr/pgsql-${version}/bin/pg_ctl ]; then
    #     cmd=/usr/pgsql-${version}/bin/pg_ctl
    # fi
    `postgresql_pg_ctl` -D $data -o "-p $port" restart
    # if [ "$(id -u -n)" == "postgres" ]; then
        
    # else
    #     $(postgresql_pg_ctl) -D $data -o "-p $port" restart
    # fi
}

postgresql_pg_ctl(){
    local _prfx=
    if [ "$(id -u -n)" != "postgres" ]; then
        _prfx="sudo -u postgres"
    fi
    if [ -f /usr/lib/postgresql/${version}/bin/pg_ctl ]; then
        echo "$_prfx /usr/lib/postgresql/${version}/bin/pg_ctl"
    elif [ -f /usr/pgsql-${version}/bin/pg_ctl ]; then
        echo "$_prfx /usr/pgsql-${version}/bin/pg_ctl"
    else
        echo "$_prfx /usr/bin/pg_ctl"
    fi
}

postgresql_ctl(){
    # local cmd=/usr/pgsql-${version}/bin/pg_ctl

    # if [ -d /usr/lib/postgresql/${version}/bin ]; then
    #     cmd=/usr/lib/postgresql/${version}/bin/pg_ctl
    # fi
    # echo $@
    $(postgresql_pg_ctl) $@
}

postgres_exec(){
    local _prfx=
    if [ "$(id -u -n)" != "postgres" ]; then
        _prfx="sudo -u postgres"
    fi
    $_prfx $@
    # if [ "$(id -u -n)" == "postgres" ]; then
    #     $cmd
    # else
    #     sudo -u postgres $cmd
    # fi
}

postgresql_init(){
    local version=$POSTGRESQL_VERSION
    local data=
        # local log=
    # local port=5432

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    data=${data:-"/var/lib/postgresql/${version}/data"}
    # log=${log:-"/var/log/postgresql-${version}.log"}

    if [[ ( ! -d $data ) || ( ! "$(ls -A $data)" ) ]]; then
        echo "Init postgresql $version: $data"
        # sudo mkdir -p $data
        # sudo chown postgres:postgres $data

        postgresql_ctl -D $data init
        # else
        #     sudo -u postgres /usr/pgsql-${version}/bin/pg_ctl -D $data init
        # fi
    fi

    if ! postgres_exec grep '0.0.0.0/0' $data/pg_hba.conf ; then
        echo 'host      all     all     0.0.0.0/0 md5' | postgres_exec tee -a $data/pg_hba.conf
    fi
    
    postgres_exec sed -i -e 's/ident$/md5/g' $data/pg_hba.conf
    postgres_exec sed -i -e "s/fr_CA/en_US/g" $data/postgresql.conf

    # sudo -u postgres sed -i -e 's/ident$/md5/g' $data/pg_hba.conf

    # sudo sed -i -e "s/fr_CA/en_US/g" $data/postgresql.conf


	# systemctl enable postgresql-${version}
    # sudo -u postgres /usr/pgsql-${version}/bin/pg_ctl -D $data -l $log  restart
	# systemctl restart postgresql-${version}

    # postgresql_start --data=$data --log=$log --port=$port
	# sleep 2
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

    DB_USER=${DB_USER:-'postgres'}

    if [[ -z "$DB_PASSWORD" ]]; then
        cat $file | psql "postgresql://$DB_USER@${DB_HOST:-localhost}/$DB_NAME";
    else
        cat $file | psql "postgresql://$DB_USER:$DB_PASSWORD@${DB_HOST:-localhost}/$DB_NAME"
    fi
}

