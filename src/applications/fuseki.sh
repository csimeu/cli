#!/bin/bash



fuseki_install() {
    
    local name=fuseki
    local data=
    local version=3.14.0
    local install_dir=/usr/share
    local catalina_home=${CATALINA_HOME:-"/usr/share/tomcat"}

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi


    curl -fSL https://archive.apache.org/dist/jena/binaries/apache-jena-fuseki-$version.tar.gz -o apache-jena-fuseki-$version.tar.gz
    tar -xzf apache-jena-fuseki-"$version".tar.gz -C "${install_dir}"
    cp -f "${install_dir}/apache-jena-fuseki-${version}/fuseki.war" "${catalina_home}/webapps/$name.war"


    mkdir -p /etc/$name/configuration
    chown tomcat:tomcat -R /etc/$name
}
