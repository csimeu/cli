#!/bin/bash

# Install prometheus
# https://www.fosslinux.com/10398/how-to-install-and-configure-prometheus-on-centos-7.htm

function install_node_exporter() 
{
    set -e
    local appName=node_exporter
    local version=1.5.0
    # local port=9100
    # local INSTALL_DIR=/opt/exporter
    # echo $@
    local _parameters=
    read_application_arguments $@
    if [ -n "$_parameters" ]; then set $_parameters; fi

    if ! getent passwd prometheus > /dev/null 2>&1; then
        sudo groupadd --system prometheus
        sudo useradd --no-create-home --shell /bin/false -g prometheus prometheus
    fi
    
    if [ ! -f /tmp/node_exporter-$version.tar.gz ];
    then
      curl -fSL https://github.com/prometheus/node_exporter/releases/download/v$version/node_exporter-$version.linux-amd64.tar.gz -o /tmp/node_exporter-$version.tar.gz
    fi

    # sudo mkdir -p ${INSTALL_DIR}
    cd /tmp
    tar -xzf node_exporter-$version.tar.gz && rm -f node_exporter-$version.tar.gz
    rm -rf /usr/bin/node_exporter && sudo mv node_exporter-$version.linux-amd64/node_exporter /usr/bin/node_exporter
    rm -rf node_exporter-$version.linux-amd64

    if [[ -d /etc/systemd && ! -f /etc/systemd/system/node_exporter.service ]]; then
      # sudo touch /etc/systemd/system/node_exporter.service
      if [ ! -f /etc/default/node_exporter ]; then sudo touch /etc/default/node_exporter; fi
      sudo tee  /etc/systemd/system/node_exporter.service << EOF >> /dev/null
[Unit]
Description=Prometheus Node Exporter
Documentation=https://github.com/prometheus/node_exporter
After=network-online.target

[Service]
User=prometheus
EnvironmentFile=/etc/default/node_exporter
ExecStart=/usr/bin/node_exporter \$OPTIONS
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    # systemctl enable node_exporter
    # sudo systemctl unmask node_exporter.service

  fi
}





function exporter_install() 
{
    set -e
    local _modules=
    local INSTALL_DIR=/opt/exporter
    # echo $@
    local _parameters=
    read_application_arguments $@
    if [ -n "$_parameters" ]; then set $_parameters; fi

    sudo mkdir -p ${INSTALL_DIR}
    if ! getent passwd prometheus > /dev/null 2>&1; then
        sudo groupadd --system prometheus
        sudo useradd --no-create-home --shell /bin/false -g prometheus prometheus
    fi
    
    for module in $_modules; do
      cmd="install_${module}_exporter"
      install_${module}_exporter --install-dir=$INSTALL_DIR
    done
    
}
