#!/bin/bash

# Install prometheus
# https://www.fosslinux.com/10398/how-to-install-and-configure-prometheus-on-centos-7.htm

# Reads arguments options
function parse_prometheus_arguments()
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

function prometheus_install() 
{
    set -e
      cd /tmp
    local version=2.24.1
    local data=
    local port=9099
    # local prometheus_config=
    # local file_config=
    # local INSTALL_DIR=/usr/share
    # echo $@
    local _parameters=
    parse_prometheus_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    # data=${data:-"$1"}
    # data=${data%"/"} 
    # INSTALL_DIR=${INSTALL_DIR%"/"} 
    useradd --no-create-home --shell /bin/false prometheus
    mkdir /etc/prometheus /var/lib/prometheus
    chown prometheus:prometheus /etc/prometheus /var/lib/prometheus
    
    curl -fSL  https://github.com/prometheus/prometheus/releases/download/v${version}/prometheus-${version}.linux-amd64.tar.gz -o prometheus-$version.tar.gz
    tar -xvzf prometheus-$version.tar.gz
    mv prometheus-$version.linux-amd64 prometheuspackage
    #
    cp prometheuspackage/prometheus /usr/local/bin/
    cp prometheuspackage/promtool /usr/local/bin/
    chown prometheus:prometheus /usr/local/bin/prometheus
    chown prometheus:prometheus /usr/local/bin/promtool
    #
    cp -r prometheuspackage/consoles /etc/prometheus
    cp -r prometheuspackage/console_libraries /etc/prometheus
    chown -R prometheus:prometheus /etc/prometheus/consoles
    chown -R prometheus:prometheus /etc/prometheus/console_libraries
    #
    vim /etc/prometheus/prometheus.yml

echo "
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus_master'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:$port']
" > /etc/prometheus/prometheus.yml

    chown prometheus:prometheus /etc/prometheus/prometheus.yml

echo "
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
#User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--web.listen-address 0.0.0.0:$port \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/prometheus.service

    systemctl daemon-reload
    systemctl enable prometheus


}


