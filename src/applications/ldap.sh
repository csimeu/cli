#!/bin/bash

# https://www.thegeekstuff.com/2015/01/openldap-linux/
# https://www.itzgeek.com/how-tos/linux/centos-how-tos/step-step-openldap-server-configuration-centos-7-rhel-7.html
# https://community.cloudera.com/t5/Community-Articles/How-to-setup-OpenLDAP-2-4-on-CentOS-7/ta-p/249263
# # https://www.tecmint.com/install-openldap-server-for-centralized-authentication/
# https://linuxhostsupport.com/blog/how-to-install-ldap-on-centos-7/

# centos 7



ldap_install() {
    _major_centos_version=$(rpm -E %{rhel})
    if [[ "$_major_centos_version" == "7" ]];
    then 
        install openldap compat-openldap openldap-clients openldap-servers openldap-servers-sql openldap-devel
    fi

    if [[ "$_major_centos_version" == "8" ]];
    then 
        # for centos 8 -> https://kifarunix.com/install-and-setup-openldap-on-centos-8/
        # for centos 8 -> https://repo.symas.com/sofl/rhel8/
        # yum config-manager --add-repo https://repo.symas.com/configs/SOFL/rhel8/sofl.repo
        # yum update
        install symas-openldap-clients symas-openldap-servers
    fi
}

## detect if a script is being sourced or not
# if [[ $_ == $0 ]] 
# then
# 	ldap_install "$@"
# fi
