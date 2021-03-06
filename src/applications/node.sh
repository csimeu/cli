#!/bin/bash


node_install() {
    rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg

    yum install -y mod_ssl nodejs npm yarn

    if [[ -n "$http_proxy" ]]; then 
        npm config set proxy $http_proxy -g; 
    fi

    npm install -g n && n stable
}

