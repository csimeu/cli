#!/bin/bash

mongodb_install() {
    echo "[MongoDB]" > /etc/yum.repos.d/mongodb.repo; \
    echo "name=MongoDB Repository" >> /etc/yum.repos.d/mongodb.repo; \
    echo "baseurl=http://repo.mongodb.org/yum/redhat/7/mongodb-org/4.2/x86_64/" >> /etc/yum.repos.d/mongodb.repo; \
    echo "gpgcheck=1" >> /etc/yum.repos.d/mongodb.repo; \
    echo "enabled=1" >> /etc/yum.repos.d/mongodb.repo; \
    echo "gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc" >> /etc/yum.repos.d/mongodb.repo;

    install mongodb-org
    execute systemctl unmask mongodb
}
