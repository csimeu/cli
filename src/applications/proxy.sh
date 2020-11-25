#!/bin/bash

function proxy_usage()
{
    echo "Usage:"
    echo "    ${cmd//_/:} [command] "
    echo ""
    echo "Commands:"
    echo "  config                 Sets proxy configuration"
    echo "Arguments:"
    echo "  --                 Username"
    echo ""
    echo "Options:"
    echo "  -h, --help              Display this help message"
    echo "      --uid               User ID"
    echo "      --gid               User's group ID"
    echo "      --home              User's home "
    echo "      --password          User's password"
    echo "      --group            Sets groups to user"
    echo "  -f, --update            Update user if already exist"
    echo ""
    echo "Help:"
    echo "  The ${cmd//_/:} Add or update user"
    echo ""
    echo "  $0 ${cmd//_/:} centos"
    echo "  $0 ${cmd//_/:} centos --uid=2000 --gid=2000 --password=pwd123 --group=wheel"
    echo ""
}

# Reads arguments options
function parse_proxy_arguments()
{
  # if [ $# -ne 0 ]; then
    local TEMP=`getopt -o p:: --long http::,https::,no-proxy:: -n "$0" -- "$@"`
    
	eval set -- "$TEMP"
    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            --http) http="-u ${2}" ; shift 2 ;;
            --https) https="-g ${2}" ; shift 2 ;;
            --no-proxy) noproxy+="${2} "; shift 2 ;;
            --) shift ; break ;;
            *) echo "Internal error! $1" ; exit 1 ;;
        esac
    done

    shift $(expr $OPTIND - 1 )
    _parameters=$@
}


# 
function proxy_set_config() 
{
    set -e
    local help=0
    local http=
    local https=
    local noproxy=

    local _parameters=
    parse_proxy_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    local proxy=${http:-"$https"}
    proxy=${proxy:-"$1"}
    https=${https:-"$http"}

    if [ -z "$proxy" ]; then
        exit 0
    fi

    export http_proxy=$http
    export https_proxy=$https
    export no_proxy=$noproxy

    if [[ -f /etc/yum.conf ]]; then 
        echo "proxy=$proxy" >> /etc/yum.conf;
    fi
}

function proxy_unset() 
{
    set -e
    unset http_proxy
    unset https_proxy
    unset no_proxy

    if [[ -f /etc/yum.conf ]]; then 
        sed -i '/^proxy .*/d' /etc/yum.conf
    fi
}
