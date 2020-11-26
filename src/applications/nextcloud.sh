#!/bin/bash


nexcloud_install() {
    _VERSION=${1:-"latest"}
    _DESTINATION=${2:-"/var/www"}
    # Download
    cd $_DESTINATION && \
    curl -fSL https://download.nextcloud.com/server/releases/$_VERSION.tar.bz2  -o nextcloud-$_VERSION.tar.bz2 && \
    tar -jxf nextcloud-$_VERSION.tar.bz2  # Extract files

    #  Create nextcloud data folder
    mkdir $_DESTINATION/nextcloud/data
    chown -R apache:apache $_DESTINATION/nextcloud/
}
