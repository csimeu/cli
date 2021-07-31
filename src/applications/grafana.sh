#!/bin/bash

# Install grafana 
# https://www.fosslinux.com/8328/how-to-install-and-configure-grafana-on-centos-7.htm

# Reads arguments options
function parse_grafana_arguments()
{
  # if [ $# -ne 0 ]; then
    local TEMP=`getopt -o p:: --long data::,version::,port::,config-file:: -n "$0" -- "$@"`
    
	eval set -- "$TEMP"
    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            --install-dir) INSTALL_DIR=${2:-"$INSTALL_DIR"} ; shift 2 ;;
            --data) data=${2%"/"} ; shift 2 ;;
            --file-config) config_file=${2:-"$config_file"}; shift 2 ;;
            --version) version=${2:-"$version"}; shift 2 ;;
            --port) port=${2:-"$port"}; shift 2 ;;
            --users-config) users_config=${2:-"$users_config"}; shift 2 ;;
            # --db-name) DB_NAME=${2:-"$DB_NAME"}; shift 2 ;;
            # --db-user) DB_USER=${2:-"$DB_USER"}; shift 2 ;;
            # --db-password) DB_PASSWORD=${2:-"$DB_PASSWORD"}; shift 2 ;;
            # --db-host) DB_HOST=${2:-"$DB_HOST"}; shift 2 ;;
            # --port) port=${2:-"$port"}; shift 2 ;;
            --) shift ; break ;;
            *) echo "Internal error! $1" ; exit 1 ;;
        esac
    done

    shift $(expr $OPTIND - 1 )
    _parameters=$@
    
  # fi
}

function grafana_install() 
{
    set -e
      
    if [ ! -f /etc/yum.repos.d/grafana.repo ]; then 
        sudo cat > /etc/yum.repos.d/grafana.repo << EOF
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF
    fi
    
    install -y grafana
    install -y fontconfig freetype* urw-fonts

    # sudo systemctl enable grafana-server.service

}


