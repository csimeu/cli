#!/bin/bash

# Install a httpd

function mysql_install() 
{
    set -e
	local _major_centos_version=$(rpm -E %{rhel})
    local _version="${1:-"5.7"}"
	local MYSQL_RPM="mysql57-community-release-el$_major_centos_version-9.noarch.rpm"
    
	
	if [[ ! $_major_centos_version =~ 6 ]];
	then
		if [[ $_version =~ ^8.*$ ]];
		then 
			MYSQL_RPM=mysql80-community-release-el$_major_centos_version-1.noarch.rpm
		fi
		wget https://dev.mysql.com/get/$MYSQL_RPM
		rpm -ivh "${MYSQL_RPM}"
	fi
     

	yum -y install mysql-server &&
	(if [[ $_major_centos_version =~ 6 ]]; then chkconfig --add mysqld ; else systemctl enable mysqld; fi)
	
	
	# mysqld --initialize-insecure --user=mysql; 
}


mysql_init(){
    local version=11
    local data=
    local user=
    local password=


    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

	# mysqld --initialize-insecure --user=mysql;
	# get temporary password
	# grep 'temporary password' /var/log/mysqld.log
	# How to remove root password
	# mysqladmin -u root -p"temporary password" password ''
	echo 'validate_password = OFF' >> /etc/my.cnf

	service mysqld restart
	if [ -f /var/log/mysqld.log ] ; then
		tmp_pwd_line=$(grep 'temporary password' /var/log/mysqld.log)
		tmp_pwd=${tmp_pwd_line##*root@localhost\:}
		tmp_pwd=${tmp_pwd#"${tmp_pwd%%[![:space:]]*}"}
		if [ -n "$tmp_pwd" ] ; then
			echo "Trying to remove root@localhost password: $tmp_pwd"
			mysqladmin -u root -p${tmp_pwd} password '' && \
			sed -i -e "s/temporary password/temporary_password/" /var/log/mysqld.log
		fi
	fi

	if [ -n "$user" ] ; then
		EXISTS_DB_USER="$(mysql -u root -sse "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$user')")"
		if [ "$EXISTS_DB_USER" = 0 ]; then
			mysql -u root --execute="CREATE USER '$user'@'%' IDENTIFIED BY '$password'; GRANT ALL PRIVILEGES ON *.* TO '$user'@'%'; FLUSH PRIVILEGES; ";
		fi
	fi


}


mysql_createdb() {
	db=${1}
	mysql -u root --execute="DROP SCHEMA IF EXISTS $db;"
	mysql -u root --execute="CREATE SCHEMA IF NOT EXISTS $db DEFAULT CHARACTER SET utf8;"
}
