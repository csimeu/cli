#!/bin/bash

# Install mariadb https://www.tecmint.com/install-mariadb-in-centos-6/

function mariadb_install() 
{
    set -e
    local _version="${1:-"5.7"}"
	local MYSQL_RPM="mysql57-community-release-el7-9.noarch.rpm"
    
	if [[ $_version =~ ^8.*$ ]];
	then 
		MYSQL_RPM=mysql80-community-release-el7-1.noarch.rpm
	fi
     
	wget https://dev.mysql.com/get/$MYSQL_RPM
	rpm -ivh "${MYSQL_RPM}" && \
	yum -y install mysql-server &&
	systemctl enable mysqld
	
	# mysqld --initialize-insecure --user=mysql; 
}

# ## detect if a script is being sourced or not
# if [[ $_ == $0 ]] 
# then
# 	mariadb_install "$@"
# fi
