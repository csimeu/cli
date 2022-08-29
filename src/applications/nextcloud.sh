#!/bin/bash


nextcloud_install() {
    _VERSION=${1:-"latest"}
    _DESTINATION=${2:-"/var/www"}
    # Download
    cd $_DESTINATION && \
    https://download.nextcloud.com/server/releases/nextcloud-23.0.7.tar.bz2
    _VERSION=23.0.7
    curl -fSL https://download.nextcloud.com/server/releases/nextcloud-$_VERSION.tar.bz2  -o nextcloud-$_VERSION.tar.bz2 && \
    tar -jxf nextcloud-$_VERSION.tar.bz2  # Extract files

    #  Create nextcloud data folder
    mkdir $_DESTINATION/nextcloud/data
    chown -R apache:apache $_DESTINATION/nextcloud/
}
