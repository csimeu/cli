#!/bin/bash

# Reads arguments options
function parse_elk_arguments()
{
    local TEMP=`getopt -o p:: --long version::,beats:: -n "$0" -- "$@"`
    
	eval set -- "$TEMP"
    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            --version) version=${2:-"$version"}; shift 2 ;;
            # --tomcat-config) tomcat_config=${2:-"$tomcat_config"}; shift 2 ;;
            --users-config) users_config=${2:-"$users_config"}; shift 2 ;;
            # --db-name) DB_NAME=${2:-"$DB_NAME"}; shift 2 ;;
            # --db-user) DB_USER=${2:-"$DB_USER"}; shift 2 ;;
            # --db-password) DB_PASSWORD=${2:-"$DB_PASSWORD"}; shift 2 ;;
            # --db-host) DB_HOST=${2:-"$DB_HOST"}; shift 2 ;;
            # --db-port) DB_PORT=${2:-"$DB_PORT"}; shift 2 ;;
            --) shift ; break ;;
            *) echo "Internal error! $1" ; exit 1 ;;
        esac
    done

    shift $(expr $OPTIND - 1 )
    _parameters=$@
    
  # fi
}

elk_import_rpm() {
    local version=$1
    echo "[elasticsearch-${version}.x]" > /etc/yum.repos.d/elasticsearch-${version}.x.repo; \
    echo "name=Elasticsearch repository for ${version}.x packages" >> /etc/yum.repos.d/elasticsearch-${version}.x.repo; \
    echo "baseurl=https://artifacts.elastic.co/packages/${version}.x/yum" >> /etc/yum.repos.d/elasticsearch-${version}.x.repo; \
    echo "gpgcheck=1" >> /etc/yum.repos.d/elasticsearch-${version}.x.repo; \
    echo "gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch" >> /etc/yum.repos.d/elasticsearch-${version}.x.repo; \
    echo "enabled=1" >> /etc/yum.repos.d/elasticsearch-${version}.x.repo; \
    echo "autorefresh=1" >> /etc/yum.repos.d/elasticsearch-${version}.x.repo; \
    echo "type=rpm-md" >> /etc/yum.repos.d/elasticsearch-${version}.x.repo
    rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
}

elk_install_beats() {
    sudo yum install -y filebeat auditbeat metricbeat packetbeat heartbeat-elastic
}

elk_install() {
    local version=7
    local _parameters=
    parse_elk_arguments $@ 
    elk_import_rpm $version
    sudo yum -y install elasticsearch logstash kibana
}

## detect if a script is being sourced or not
# if [[ $_ == $0 ]] 
# then
# 	elk_install "$@"
# fi





