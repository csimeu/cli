#!/bin/bash

# Install a httpd

function mysql_install() 
{
    set -e
    local appName=mysql

    local FORCE=0
    local IS_DEFAULT=0
    local version=$MYSQL_DEFAULT_VERSION

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

	
	cd /tmp/releases

    case `plateform` in
        alpine) install apk add --update mysql mysql-client ;;
        redhat)
			local MYSQL_RPM="mysql57-community-release-el7-9.noarch.rpm"

			# fixed Public key for mysql-community-xxx.rpm is not installed https://segmentfault.com/a/1190000041433962
			sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022

			if [[ $version =~ ^8.*$ ]];
			then 
				MYSQL_RPM=mysql80-community-release-el$OS_VERSION-1.noarch.rpm
			fi

			# if [[ ! -f /etc/yum.repos.d/pgdg-redhat-all.repo ]]; then
			if [[ ! -f /tmp/releases/$MYSQL_RPM ]]; then
				curl -fSL https://dev.mysql.com/get/$MYSQL_RPM -o /tmp/releases/$MYSQL_RPM
				# wget https://dev.mysql.com/get/$MYSQL_RPM
			fi
			execute rpm -ivh "/tmp/releases/${MYSQL_RPM}"
			install mysql-server
            ;;
        debian)
			local MYSQL_DEB="mysql-apt-config_0.8.16-1_all.deb"
			if [[ $version =~ ^8.*$ ]];
			then 
				# wget https://dev.mysql.com/get/mysql-apt-config_0.8.16-1_all.deb
				if [[ ! -f /tmp/releases/$MYSQL_DEB ]]; then
					curl -fSL https://dev.mysql.com/get/$MYSQL_DEB -o /tmp/releases/$MYSQL_DEB
				fi
				
				apt-get install /tmp/releases/$MYSQL_DEB
			fi
			install mysql-server
        ;;
    esac
	
    if [[ -n "$ADMIN_USER" && $(getent passwd $ADMIN_USER)  ]]; then sudo usermod -aG mysql $ADMIN_USER; fi

    case `plateform` in 
        redhat)
			if [ -f /usr/libexec/mysqld ]; then sudo setcap -r /usr/libexec/mysqld; fi
			if [ -f /usr/libexec/mysql-check-socket ]; then 
				sudo /usr/libexec/mysql-check-socket
				sudo /usr/libexec/mysql-prepare-db-dir %n
			else
				sudo /usr/sbin/mysqld --initialize-insecure  --user=mysql
				sudo /usr/bin/mysqld_pre_systemd
			fi
			if [[ $OS_VERSION =~ 6 ]]; then execute chkconfig --add mysqld ; else execute systemctl enable mysqld; fi
            ;;
        debian)
			execute systemctl enable mysql;
        ;;
    esac
}


mysql_setup(){
    local version=11
    local data=

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

	# mysqld --initialize-insecure --user=mysql;
	# get temporary password
	# grep 'temporary password' /var/log/mysqld.log
	# How to remove root password
	# mysqladmin -u root -p"temporary password" password ''
	echo 'validate_password = OFF' >> /etc/my.cnf

	# systemctl enable mysqld --now
	mysql_service restart
	local log_file=/var/log/mysqld.log

	if [ -f $log_file ] ; then
		tmp_pwd_line=$(grep 'temporary password' $log_file)
		tmp_pwd=${tmp_pwd_line##*root@localhost\:}
		tmp_pwd=${tmp_pwd#"${tmp_pwd%%[![:space:]]*}"}
		if [ -n "$tmp_pwd" ] ; then
			echo "Trying to remove root@localhost password: $tmp_pwd"
			mysqladmin -u root -p${tmp_pwd} password '' && \
			sed -i -e "s/temporary password/temporary_password/" $log_file
		fi
	fi
 	
	# mysql_createuser >> /log.txt
	# MYSQL_DATABASES=${MYSQL_DATABASES:-$DATABASES}
	# for database in $MYSQL_DATABASES; do
	# 	echo "create database: cpm mysql:createdb --db-name=$database --db-user=$database --db-password=$database.123 "
	# 	mysql_createdb --db-name=$database --db-user=$database --db-password=$database.123 >> /log.txt
	# done

	# local install_file=mysql-install-database.sql
	# if [[ -f $APP_DIR/dist/$install_file && -n $DB_NAME ]]; then
	# 	echo "running $APP_DIR/dist/$install_file"
	# 	sudo mysql $DB_NAME < $APP_DIR/dist/$install_file  >> /log.txt
	# fi

	# for directory in $APPS_DIR/ ; do
	# 	if [[ -f $directory/dist/$install_file && -n $DB_NAME ]]; then
	# 		echo "running $directory/dist/$install_file"
	# 		sudo mysql $directory < $directory/dist/$install_file  >> /log.txt
	# 	fi
	# done
}


mysql_createdb() {
	local FORCE=0
	local DB_HOST='%'
    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi
	
    if [[ -z "$DB_NAME" ]]; then
        echo "===>> ERROR: --db-name={DB_NAME} required"
        exit 0;
    fi
	
	if [ "$FORCE" == "1" ]; then sudo mysql --execute="DROP SCHEMA IF EXISTS $DB_NAME;" ; fi
	
	sudo mysql --execute="CREATE SCHEMA IF NOT EXISTS $DB_NAME DEFAULT CHARACTER SET utf8;"

	if [[ -n "$DB_USER" ]] ; then
		EXISTS_DB_USER="$(mysql_existuser $DB_USER ${DB_HOST:-localhost})"
		if [ "$EXISTS_DB_USER" = 0 ]; then
			sudo mysql --execute="CREATE USER '$DB_USER'@'${DB_HOST:-localhost}';";
			echo "CREATE USER '$DB_USER'@'${DB_HOST:-localhost}';"
		fi
		if [[ -n "$DB_PASSWORD" ]]; then
			# echo "ALTER USER '$DB_USER'@'${DB_HOST:-localhost}' IDENTIFIED BY '$DB_PASSWORD'"
			sudo mysql --execute="ALTER USER '$DB_USER'@'${DB_HOST:-localhost}' IDENTIFIED BY '$DB_PASSWORD'; FLUSH PRIVILEGES;";
			echo "SET PASSWORD '$DB_USER'@'${DB_HOST:-localhost}'"
		fi

		sudo mysql --execute="GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'${DB_HOST:-localhost}'; FLUSH PRIVILEGES;";
	fi
}

mysql_existuser() {
	local username=$1
	local hostname=${2:-localhost}
	# local DB_HOST='%'
	# echo "sudo mysql -sse \"SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$DB_USER@${DB_HOST:-localhost}')\""
	EXISTS_DB_USER="$(sudo mysql -sse "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$username' AND host = '${hostname:-localhost}');")"
	echo $EXISTS_DB_USER;
}

mysql_createuser() {
    local _parameters=
	local DB_HOST='%'
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

	if [[ -n "$DB_USER" ]] ; then
		EXISTS_DB_USER="$(mysql_existuser $DB_USER ${DB_HOST:-localhost})"
		if [ "$EXISTS_DB_USER" = 0 ]; then
			sudo mysql --execute="CREATE USER '$DB_USER'@'${DB_HOST:-localhost}';";
			echo "CREATE USER '$DB_USER'@'${DB_HOST:-localhost}';"
		fi

		# Change user password if user already exist
		if [[ -n "$DB_PASSWORD" ]]; then
			# echo "ALTER USER '$DB_USER'@'${DB_HOST:-localhost}' IDENTIFIED BY '$DB_PASSWORD'"
			sudo mysql --execute="ALTER USER '$DB_USER'@'${DB_HOST:-localhost}' IDENTIFIED BY '$DB_PASSWORD'; FLUSH PRIVILEGES;";
			echo "SET PASSWORD '$DB_USER'@'${DB_HOST:-localhost}'"
		fi

		# Create database
		if [[ -n "$DB_NAME" ]]; then
			sudo mysql --execute="CREATE SCHEMA IF NOT EXISTS $DB_NAME DEFAULT CHARACTER SET utf8;";
			sudo mysql --execute="GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'${DB_HOST:-localhost}'; FLUSH PRIVILEGES;";
			echo "CREATE DATABASE $DB_NAME and grant all privileges to '$DB_USER'@'${DB_HOST:-localhost}'"
		fi
	fi
}

mysql_update_password() {
    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

	if [[ -n "$DB_USER" ]] ; then
		EXISTS_DB_USER="$(mysql_existuser $DB_USER ${DB_HOST:-localhost})"
		if [ "$EXISTS_DB_USER" = 0 ]; then
			echo "ERROR:  user '$DB_USER'@'${DB_HOST:-localhost}' not found !";
			exit 1;
		fi

		# Change user password 
		if [[ -n "$DB_PASSWORD" ]]; then
			sudo mysql --execute="ALTER USER '$DB_USER'@'${DB_HOST:-localhost}' IDENTIFIED BY '$DB_PASSWORD'; FLUSH PRIVILEGES;";
		fi
	fi
}



