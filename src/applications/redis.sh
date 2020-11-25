#!/bin/bash

redis_install() {
    yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
    yum-config-manager --enable remi 
    yum -y install redis
}

