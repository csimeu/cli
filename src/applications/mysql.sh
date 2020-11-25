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

