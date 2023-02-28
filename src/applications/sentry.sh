#!/bin/bash

function sentry_install() 
{
    set -e

    local appName=sentry

    local FORCE=0
    local IS_DEFAULT=0
    local version=
    local data=/var/lib
    local name=


    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi


    name="${name:-$appName}"
    data_dir="${data_dir:-/var/lib/$name}"
    home_dir="${home_dir:-/usr/share/$name}"
    
    # python_install
    install build-essential libxslt1-dev gcc libffi-dev libjpeg-dev libxml2-dev libyaml-dev libpq-dev supervisor
    install libxml2 libxmlsec1 pkg-config xmlsec1 libxmlsec1-dev libsasl2-dev libldap2-dev libssl-dev

    # execute mkdir -p $home_dir

    if ! getent passwd $name > /dev/null 2>&1; then
        execute groupadd --system $name
        execute useradd -d $home_dir -r -s /bin/false -g $name $name
    fi

    sudo mkdir -p $home_dir $data_dir && chown $name:$name -R $home_dir $data_dir

    if [[ -n "$version" ]]; then
        pip_install sentry==$version
    else
        pip_install sentry
    fi
    # if [[ -n "$http_proxy" ]]; then
    #     execute pip install --proxy $http_proxy sentry
    #     execute pip install --proxy $http_proxy sentry-ldap-auth python-memcached
    # else
    #     execute pip install sentry
    pip_install sentry-ldap-auth python-memcached
    # fi

    # sudo -u $name $home_dir/.local/bin/sentry init
    
    # SENTRY_CONF=/etc/sentry
    # sudo mv $SENTRY_HOME/.sentry/ /etc/$name

    # sudo tee -a "SENTRY_CONF=" 
    # if -f /etc/environment
    # sudo mv .sentry/ /etc/sentry

    # export PATH=$HOME/.local/bin:$PATH
    # export 


    echo ">> Installed application '$appName' (version = $version) in $SENTRY_HOME"
}


sentry_start(){
    local config_file=${1:-"/etc/redis/redis.conf"}
    cmdline="/usr/bin/redis-server $config_file --supervised systemd --daemonize no"
    if [ "$(id -u -n)" == "redis" ]; then 
        $cmdline &
    else 
        sudo -u redis $cmdline &
    fi
}
