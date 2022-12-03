#!/bin/bash

# Install grafana 
# https://www.fosslinux.com/8328/how-to-install-and-configure-grafana-on-centos-7.htm


grafana_add_repolist() {
    case `plateform_name` in 
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
    esac
}


function grafana_install() 
{
    set -e
    
    grafana_add_repolist
    install grafana

    # sudo systemctl enable grafana-server.service

}


