#!/bin/bash

# Install grafana 
# https://www.fosslinux.com/8328/how-to-install-and-configure-grafana-on-centos-7.htm


grafana_add_repolist() {
    case `platform_name` in 
        redhat|fedora)  
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
            install fontconfig freetype* urw-fonts
        ;;

        debian|ubuntu)  
            # https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/
            if [ ! -f /etc/apt/sources.list.d/grafana.list ]; then
                install apt-transport-https software-properties-common wget
                sudo wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
                echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
            fi
        ;;
    esac
}


function grafana_install() 
{
    set -e
    
    grafana_add_repolist
    install grafana
    sudo mkdir -p /run/grafana
    sudo chmod ugo+w /run/grafana

    # sudo systemctl enable grafana-server.service

}


