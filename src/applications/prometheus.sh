#!/bin/bash

# Install prometheus
# https://www.fosslinux.com/10398/how-to-install-and-configure-prometheus-on-centos-7.htm

# # Reads arguments options
# function parse_prometheus_arguments()
# {
#   # if [ $# -ne 0 ]; then
#     local TEMP=`getopt -o p:: --long data::,version::,port::,config-file:: -n "$0" -- "$@"`
    
# 	eval set -- "$TEMP"
#     # extract options and their arguments into variables.
#     while true ; do
#         case "$1" in
#             --install-dir) INSTALL_DIR=${2:-"$INSTALL_DIR"} ; shift 2 ;;
#             --data) data=${2%"/"} ; shift 2 ;;
#             --file-config) config_file=${2:-"$config_file"}; shift 2 ;;
#             --version) version=${2:-"$version"}; shift 2 ;;
#             --port) port=${2:-"$port"}; shift 2 ;;
#             --users-config) users_config=${2:-"$users_config"}; shift 2 ;;
#             # --db-name) DB_NAME=${2:-"$DB_NAME"}; shift 2 ;;
#             # --db-user) DB_USER=${2:-"$DB_USER"}; shift 2 ;;
#             # --db-password) DB_PASSWORD=${2:-"$DB_PASSWORD"}; shift 2 ;;
#             # --db-host) DB_HOST=${2:-"$DB_HOST"}; shift 2 ;;
#             # --port) port=${2:-"$port"}; shift 2 ;;
#             --) shift ; break ;;
#             *) echo "Internal error! $1" ; exit 1 ;;
#         esac
#     done

#     shift $(expr $OPTIND - 1 )
#     _parameters=$@
    
#   # fi
# }

function prometheus_install() 
{
    set -e
    local appName=prometheus
      cd /tmp/releases
    local version=2.24.1
    local data=/var/lib/$appName
    local port=9099
    # local prometheus_config=
    # local file_config=
    # local INSTALL_DIR=/usr/share
    # echo $@
    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    # data=${data:-"$1"}
    # data=${data%"/"} 
    # INSTALL_DIR=${INSTALL_DIR%"/"} 

    if ! getent passwd $appName > /dev/null 2>&1; then
        sudo groupadd --system $appName
        sudo useradd --no-create-home --shell /bin/false -g $appName $appName
    fi
    
    
    sudo mkdir /etc/$appName /var/lib/$appName
    sudo chown $appName:$appName /etc/$appName /var/lib/$appName
    
    if [ ! -f /tmp/releases/prometheus-$version.tar.gz ];
    then 
      curl -fSL  https://github.com/prometheus/prometheus/releases/download/v${version}/prometheus-${version}.linux-amd64.tar.gz -o /tmp/releases/prometheus-$version.tar.gz
    fi
    cd /tmp/releases
    tar -xvzf /tmp/releases/prometheus-$version.tar.gz
    mv prometheus-$version.linux-amd64 prometheuspackage
    #
    sudo cp prometheuspackage/prometheus /usr/local/bin/
    sudo cp prometheuspackage/promtool /usr/local/bin/
    sudo chown prometheus:prometheus /usr/local/bin/prometheus
    sudo chown prometheus:prometheus /usr/local/bin/promtool
    #
    sudo cp -r prometheuspackage/consoles /etc/prometheus
    sudo cp -r prometheuspackage/console_libraries /etc/prometheus
    sudo chown -R prometheus:prometheus /etc/prometheus/consoles
    sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
    #
    # sudo vim /etc/prometheus/prometheus.yml

    cat > /etc/prometheus/prometheus.yml << EOF
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus_master'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:$port']
EOF
    chown prometheus:prometheus /etc/prometheus/prometheus.yml

    cat /etc/systemd/system/prometheus.service << EOF
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
EOF

    # systemctl daemon-reload
    # systemctl enable prometheus


}


