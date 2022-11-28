#!/bin/bash


elk_import_repolist() {
    # echo $(plateform)
    case `plateform` in 
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
    local version=7
    local _parameters=
    read_application_arguments $@ 
    
    elk_import_repolist
    install elasticsearch

    if [[ -n "$ADMIN_USER" && $(getent passwd $ADMIN_USER)  ]]; then sudo usermod -aG elasticsearch $ADMIN_USER; fi
    
    sudo sed -i -e "s/^\#\# -Xms.*$/-Xms512m/" /etc/elasticsearch/jvm.options
    sudo sed -i -e "s/^## -Xmx.*$/-Xmx512m/" /etc/elasticsearch/jvm.options
    sudo sed -i -e "s/^#transport.host: .*/transport.host: 0.0.0.0/" /etc/elasticsearch/elasticsearch.yml
    sudo sed -i -e "s/http.host: .*/http.host: 0.0.0.0/" /etc/elasticsearch/elasticsearch.yml
    sudo sed -i -e "s/^#http.host: .*/http.host: 0.0.0.0/" /etc/elasticsearch/elasticsearch.yml
    # execute systemctl enable elasticsearch
}

kibana_install() {
    local version=7
    local _parameters=
    parse_elk_arguments $@ 
    
    elk_import_repolist
    install kibana
    # execute systemctl enable kibana
}

## detect if a script is being sourced or not
# if [[ $_ == $0 ]] 
# then
# 	elk_install "$@"
# fi





