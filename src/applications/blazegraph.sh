#!/bin/bash

# Install blazegraph


function blazegraph_install() 
{
    set -e
    local version=2.1.5
    local data=
    local name=
    local catalina_home=/usr/share/tomcat
    local blazegraph_config=
    local file_config=
    # echo $@

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    if ! getent passwd tomcat > /dev/null 2>&1; then
        tomcat_install
    fi

    # https://nvbach.blogspot.com/2019/04/installing-blazegraph-on-linux-debian.html
    cd /tmp
    wget https://github.com/blazegraph/database/releases/download/BLAZEGRAPH_RELEASE_${version//\./_}/blazegraph.war
    mv blazegraph.war $catalina_home/webapps/


    # # Configure
    # # data=${data:-"$1"}
    # data=${data:-"/var/lib/blazegraph"}
    # data=${data%"/"} 

    # wget https://github.com/blazegraph/database/releases/download/BLAZEGRAPH_RELEASE_2_1_5/blazegraph.rpm
    # sudo yum localinstall blazegraph.rpm
    # ln -s /etc/alternatives/jre  /usr/lib/jvm/default-java

    # mkdir -p /etc/blazegraph/
    # chown tomcat:tomcat -R /etc/blazegraph/
}

## detect if a script is being sourced or not
if [[ $_ == $0 ]] 
then
  blazegraph_install $@
fi

