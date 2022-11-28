#!/bin/bash

# Install mariadb https://www.tecmint.com/install-mariadb-in-centos-6/

function mariadb_install() 
{
    set -e
    local _version="${1:-"5.7"}"
	local MYSQL_RPM="mysql57-community-release-el7-9.noarch.rpm"
    

    case `plateform` in
        alpine) install mariadb-server ;;
        redhat)
			install mariadb-server
            ;;
        debian|ubuntu)
			install mariadb-server
			sudo /usr/bin/install -m 755 -o mysql -g root -d /var/run/mysqld
			# sudo mysql --execute="GRANT ALL ON *.* TO 'admin'@'localhost' IDENTIFIED BY '' WITH GRANT OPTION; FLUSH PRIVILEGES;"
        ;;
    esac

}

# ## detect if a script is being sourced or not
# if [[ $_ == $0 ]] 
# then
# 	mariadb_install "$@"
# fiGRANT ALL ON *.* TO 'admin'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;

# sudo mysql --execute="GRANT ALL ON *.* TO 'admin'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;"


# mariadb_exist_user() {
# 	local username=$1
# 	local hostname=${2:-localhost}
# 	EXISTS_DB_USER="$(sudo mysql  -sse "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$username' AND host = '${hostname}');")"
# 	echo $EXISTS_DB_USER;
# }

# mariadb_create_user(){

#     local _parameters=
#     read_application_arguments $@ 
#     if [ -n "$_parameters" ]; then set $_parameters; fi

#     cd /tmp
#     DB_USER=${DB_USER:-"$user"}
#     DB_PASSWORD=${DB_PASSWORD:-"$password"}

# 	if [[ -n "$DB_USER" ]] ; then
#         if [ "$(id -u -n)" == "postgres" ]; then
#             EXISTS_USER="$(psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'")"
#             if [[ -z "$EXISTS_USER" ]]; then
#                 psql --command "CREATE USER $DB_USER WITH SUPERUSER ;"
#             fi
#             # Change user password if user already exist
#             if [[ -n "$DB_PASSWORD" ]]; then
#                 psql --command "ALTER USER $DB_USER with PASSWORD '$DB_PASSWORD';"
#             fi
#         else
#             EXISTS_USER="$(sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'")"
#             if [[ -z "$EXISTS_USER" ]]; then
#                 sudo -u postgres psql --command "CREATE USER $DB_USER WITH SUPERUSER ;"
#             fi
#             # Change user password if user already exist
#             if [[ -n "$DB_PASSWORD" ]]; then
#                 sudo -u postgres psql --command "ALTER USER $DB_USER with PASSWORD '$DB_PASSWORD';"
#             fi
#         fi
# 	fi
# }

# mariadb_create_db(){
#     # local version=11
#     # local data=

#     local _parameters=
#     read_application_arguments $@ 
#     if [ -n "$_parameters" ]; then set $_parameters; fi
    
#     cd /tmp
#     DB_NAME=${DB_NAME:-"$name"}
#     DB_USER=${DB_USER:-"$user"}
    
#     if [[ -z "$DB_NAME" ]]; then
#         echo "===>> ERROR: required --db-name={DB_NAME} or --name={DB_NAME} "
#         exit 0;
#     fi
#     if [[ -z "$DB_USER" ]]; then
#         echo "===>> ERROR: --db-user={DB_USER} required"
#         exit 0;
#     fi

#     if [ "$(id -u -n)" == "postgres" ]; then
#             EXISTS_DB="$(psql -tAc "SELECT datname FROM pg_catalog.pg_database WHERE datname='$DB_NAME'")"
#         if [[ -z "$EXISTS_DB" ]]; then
#             createdb -O $DB_USER $DB_NAME
#         fi

#         psql $DB_NAME --command "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
#     else
#         EXISTS_DB="$(sudo -u postgres psql -tAc "SELECT datname FROM pg_catalog.pg_database WHERE datname='$DB_NAME'")"
#         if [[ -z "$EXISTS_DB" ]]; then
#             sudo -u postgres createdb -O $DB_USER $DB_NAME
#         fi

#         sudo -u postgres psql $DB_NAME --command "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
#     fi
# }

# mariadb_start(){
#     local version=$MARIADB_VERSION
#     local port=${MARIADB_PORT:-"5432"}
#     local data=
#     local log=    

#     local _parameters=
#     read_application_arguments $@ 
#     if [ -n "$_parameters" ]; then set $_parameters; fi

#     data=${data:-"/var/lib/postgresql/${version}/data"}
#     log=${log:-"/var/log/postgresql-${version}.log"}

#     # if [[ ! -f "$log" ]]; then
#     #     sudo touch $log
#     #     sudo chown postgres:postgres $log
#     # fi

#     # mariadb_ctl -D $data -o '-p 5443' restart
#     # mariadb_ctl -D $data -l $log -o "\"-p $port\"" restart

#     local cmd=/usr/pgsql-${version}/bin/pg_ctl

#     if [ -d /usr/lib/postgresql/${version}/bin ]; then
#         cmd=/usr/lib/postgresql/${version}/bin/pg_ctl
#     fi

#     if [ "$(id -u -n)" == "postgres" ]; then
#         $cmd -D $data -o "-p $port" restart
#     else
#         sudo -u postgres $cmd -D $data -o "-p $port" restart
#     fi
# }
