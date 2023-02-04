#!/bin/bash

function sentry_install() 
{
    set -e

    local appName=sentry

    local FORCE=0
    local IS_DEFAULT=0
    local version=$SENTRY_DEFAULT_VERSION
    local data=/var/lib
    local name=


    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi


    name="${name:-$appName}"
    data_dir="${data_dir:-/var/lib/$name}"
    home_dir="${home_dir:-/usr/share/$name}"

    # python_install
    install build-essential libxslt1-dev gcc libffi-dev libjpeg-dev libxml2-dev libxslt-dev libyaml-dev libpq-dev supervisor
    install libxml2 libxmlsec1 pkg-config xmlsec1 libxmlsec1-dev

    # execute mkdir -p $home_dir

    if ! getent passwd $name > /dev/null 2>&1; then
        sudo groupadd --system $name
        sudo useradd -d $home_dir -r -s /bin/false -g $name $name
    fi

    if [[ -n "$http_proxy" ]]; then
        sudo -u $name pip install --proxy $http_proxy -U sentry
    else
        sudo -u $name pip install -U sentry
    fi

    sudo -u $name sentry init
    
    # SENTRY_CONF=/etc/sentry
    # sudo mv $SENTRY_HOME/.sentry/ /etc/$name

    # sudo tee -a "SENTRY_CONF=" 
    # if -f /etc/environment
    # sudo mv .sentry/ /etc/sentry

    # export PATH=$HOME/.local/bin:$PATH
    # export 


    echo ">> Installed application '$appName' (version = $version) in $SENTRY_HOME"
}
