#!/bin/bash

redis_install() {
    if [ ! -f /etc/yum.repo.d/remi.repo ]; then
        sudo yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
    fi
    sudo yum-config-manager --enable remi 
    sudo yum -y install redis
}

