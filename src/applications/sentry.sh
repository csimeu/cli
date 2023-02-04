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


    name="$appName"
    local SENTRY_HOME=/etc/$name

    install build-essential libxslt1-dev gcc libffi-dev libjpeg-dev libxml2-dev libxslt-dev libyaml-dev libpq-dev supervisor
    install libxml2 libxmlsec1 pkg-config xmlsec1 libxmlsec1-dev

    # execute mkdir -p $SENTRY_HOME

    if ! getent passwd $appName > /dev/null 2>&1; then
        sudo groupadd --system $appName
        sudo useradd -d $SENTRY_HOME -r -s /bin/false -g $appName $appName
    fi


    sudo -u sentry pip install -U sentry
    sudo -u sentry sentry init
    # sudo mv .sentry/ /etc/sentry

    # export PATH=$HOME/.local/bin:$PATH
    # export SENTRY_CONF=/etc/sentry


    echo ">> Installed application '$appName' (version = $version) in $SENTRY_HOME"
}
