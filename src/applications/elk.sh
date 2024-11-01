#!/bin/bash


elk_import_repolist() {
    # echo $(platform)
    case `platform` in 
        debian|ubuntu)
            # echo "debian"
            if [[ ! -f /etc/apt/sources.list.d/elastic-$version.x.list ]]; then
                wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
                echo "deb https://artifacts.elastic.co/packages/$version.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-$version.x.list
                sudo apt-get -y update
            fi
            install gnupg2 lsb-release
            ;;
        redhat)
            # echo "redhat"
            if [[ ! -f /etc/yum.repos.d/elasticsearch-${version}.x.repo ]]; then
                sudo cat > /etc/yum.repos.d/elasticsearch-${version}.x.repo << EOF
[elasticsearch-${version}.x]
name=Elasticsearch repository for ${version}.x packages
baseurl=https://artifacts.elastic.co/packages/${version}.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
            # sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
        fi
        ;;
    esac

    # # if [[ is_debian && ! -f /etc/apt/sources.list.d/elastic-$version.x.list ]]; then
    # #     wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
    # #     echo "deb https://artifacts.elastic.co/packages/$version.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-$version.x.list
    # #     sudo apt-get -y update
    # # fi
    # # snake_to_camel test
    # if [[  `is_redhat`  ]]; then
    #     # echo $(is_debian)
    #     echo $(awk -F= '/^ID_LIKE=/{print $2}' /etc/os-release)
    # # fi
    # fi
}

# elk_import_deb() {
#     if [ ! -f /etc/apt/sources.list.d/elastic-$version.x.list ]
#     then 
#         wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
#         echo "deb https://artifacts.elastic.co/packages/$version.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-$version.x.list
#         sudo apt-get -y update
#     fi
# }

elk_install_beats() {
    elk_import_repolist
    install filebeat auditbeat metricbeat packetbeat heartbeat-elastic
}

elk_install() {
    local version=7
    local _parameters=
    read_application_arguments $@ 
    
    elk_import_repolist
    install elasticsearch kibana
}

elasticsearch_install() {
    local version=8
    local _parameters=
    read_application_arguments $@ 
    
    elk_import_repolist
    install elasticsearch

    if [[ -n "$ADMIN_USER" && $(getent passwd $ADMIN_USER)  ]]; then sudo usermod -aG elasticsearch $ADMIN_USER; fi
    
    sudo sed -i -e "s/^\#\# -Xms.*$/-Xms512m/" /etc/elasticsearch/jvm.options
    sudo sed -i -e "s/^## -Xmx.*$/-Xmx512m/" /etc/elasticsearch/jvm.options
    sudo sed -i -e "s/^#transport.host: .*/transport.host: 0.0.0.0/" /etc/elasticsearch/elasticsearch.yml
    sudo sed -i -e "s/^#network.host: .*/network.host: 0.0.0.0/" /etc/elasticsearch/elasticsearch.yml
    sudo sed -i -e "s/http.host: .*/http.host: 0.0.0.0/" /etc/elasticsearch/elasticsearch.yml
    sudo sed -i -e "s/^#http.host: .*/http.host: 0.0.0.0/" /etc/elasticsearch/elasticsearch.yml

    sudo chmod g+wr -R /etc/elasticsearch
    # execute systemctl enable elasticsearch
}

kibana_install() {
    local version=$KIBANA_DEFAULT_VERSION
    local _parameters=
    local INSTALL_DIR=$INSTALL_DIR
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi
    
    case "$version" in
        "8") version=8.5.2 ;;
        *);;
    esac

    case `platform` in 
        alpine)
            install nodejs curl
            sudo curl -fSL https://artifacts.elastic.co/downloads/kibana/kibana-${version}-linux-x86_64.tar.gz -o /tmp/kibana-${version}-linux-x86_64.tar.gz
            sudo tar -xzf /tmp/kibana-${version}-linux-x86_64.tar.gz -C $INSTALL_DIR
            sudo mv $INSTALL_DIR/kibana-${version}-linux-x86_64/ $INSTALL_DIR/kibana-${version}
            sudo rm $INSTALL_DIR/kibana-${version}/node/bin/node
            sudo rm $INSTALL_DIR/kibana-${version}/node/bin/npm
            sudo ln -s $INSTALL_DIR/kibana-${version} $INSTALL_DIR/kibana
            sudo ln -s /usr/bin/node $INSTALL_DIR/kibana-${version}/node/bin/node
            sudo ln -s /usr/bin/npm $INSTALL_DIR/kibana-${version}/node/bin/npm
            sudo sed -i '/elasticsearch_url/s/localhost/elasticsearch/' $INSTALL_DIR/kibana-${version}/config/kibana.yml
            sudo rm -rf /tmp/kibana-${version}-linux-x86_64.tar.gz
            sudo ln -s $INSTALL_DIR/kibana/config /etc/kibana
        ;;
        *)
            elk_import_repolist
            install kibana
        ;;
    esac
    # execute systemctl enable kibana
}

# kibana_package() {
#     local version=8
#     local _parameters=
#     read_application_arguments $@ 
    
#     case `platform` in 
#         alpine)
#             install nodejs curl && \
#     curl -LO https://artifacts.elastic.co/downloads/kibana/kibana-${KIBANA_VERSION}-linux-x64.tar.gz && \
#     tar xzf /kibana-${KIBANA_VERSION}-linux-x64.tar.gz -C / && \
#     rm /kibana-${KIBANA_VERSION}-linux-x64/node/bin/node && \
#     rm /kibana-${KIBANA_VERSION}-linux-x64/node/bin/npm && \
#     ln -s /usr/bin/node /kibana-${KIBANA_VERSION}-linux-x64/node/bin/node && \
#     ln -s /usr/bin/npm /kibana-${KIBANA_VERSION}-linux-x64/node/bin/npm && \
#     sed -i '/elasticsearch_url/s/localhost/elasticsearch/' /kibana-${KIBANA_VERSION}-linux-x64/config/kibana.yml && \
#     rm -rf /var/cache/apk/* /kibana-${KIBANA_VERSION}-linux-x64.tar.gz

#         ;;
#     esac
#     # execute systemctl enable kibana
# }

## detect if a script is being sourced or not
# if [[ $_ == $0 ]] 
# then
# 	elk_install "$@"
# fi





