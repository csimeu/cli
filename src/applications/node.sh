#!/bin/bash


install_beats() {
    rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg

    yum install -y mod_ssl nodejs npm yarn

    if [[ -n "$http_proxy" ]]; then 
        npm config set proxy $http_proxy -g; 
    fi

    npm install -g n && n stable
    npm install -g grunt-cli @angular/cli sass less
}

