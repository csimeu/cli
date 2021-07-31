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
            --http) http="${2//\//\/\//}" ; shift 2 ;;
            --https) https="${2//\//\/\//}" ; shift 2 ;;
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

    proxy_load_config
}

# 
function proxy_load_config() 
{
    set -e

    case `plateform` in 
        debian)
            sudo rm -f /etc/apt/apt.conf.d/proxy.conf
            sudo touch /etc/apt/apt.conf.d/proxy.conf
            if [ -n "$http_proxy" ] ; then echo  "Acquire::http::Proxy \"$http_proxy/\";" | sudo tee -a /etc/apt/apt.conf.d/proxy.conf > /dev/null; fi
            if [ -n "$https_proxy" ] ; then echo  "Acquire::https::Proxy \"$https_proxy/\";" | sudo tee -a /etc/apt/apt.conf.d/proxy.conf > /dev/null; fi
            ;;
        redhat)
            local proxy=${https_proxy:-"$http_proxy"}
            if [[ -n "$proxy" ]]; then
                sudo sed -i -e "/^proxy=.*/d" /etc/yum.conf;
                echo "proxy=$proxy" | sudo tee -a /etc/yum.conf;
            fi
        ;;
    esac

    if [ -n "$http_proxy" ] ;
    then 
        ## check if command exist before
        # https://stackoverflow.com/questions/7522712/how-can-i-check-if-a-command-exists-in-a-shell-script/39983421
        # npm
        if _loc="$(type -p npm)" && [[ -n $_loc ]]; then sudo npm config -g set proxy $http_proxy; fi
        # yarn
        if _loc="$(type -p yarn)" && [[ -n $_loc ]]; then sudo yarn config -g set proxy $http_proxy; fi
        # git
        if _loc="$(type -p git)" && [[ -n $_loc ]]; then sudo git config --global http.proxy $http_proxy; fi
        
    fi

    if [ -n "$https_proxy" ] ;
    then 
        # npm
        if _loc="$(type -p npm)" && [[ -n $_loc ]]; then sudo npm config -g set https-proxy $https_proxy; fi
        # yarn
        if _loc="$(type -p yarn)" && [[ -n $_loc ]]; then sudo yarn config -g set https-proxy $https_proxy; fi
        # git
        if _loc="$(type -p git)" && [[ -n $_loc ]]; then sudo git config --global https.proxy $http_proxy; fi
        
    fi


}

proxy_unset() 
{
    set -e
    unset http_proxy
    unset https_proxy
    unset no_proxy

    case `plateform` in 
        debian)
            sudo rm /etc/apt/apt.conf.d/proxy.conf
            ;;
        redhat)
            local proxy=${https_proxy:-"$http_proxy"}
            if [[ -n "$proxy" ]]; then
                sed -i -e "/^proxy=.*/d" /etc/yum.conf;
            fi
        ;;
    esac
    
    # npm
    if _loc="$(type -p npm)" && [[ -n $_loc ]]; then 
        sudo npm config -g rm proxy; 
        sudo npm config -g rm https-proxy; 
    fi
    # yarn
    if _loc="$(type -p yarn)" && [[ -n $_loc ]]; then 
        sudo yarn config delete proxy -g; 
        sudo yarn config delete https-proxy -g; 
    fi
    # 
    if _loc="$(type -p git)" && [[ -n $_loc ]]; then 
        sudo git config --global --unset https.proxy
        sudo git config --global --unset http.proxy
    fi
        
}

yum_set_proxy() 
{
    case `plateform` in 
        redhat)
            local proxy=${1:-$https_proxy}
            proxy=${proxy:-$http_proxy}
            if [[ -n "$proxy" ]]; then
                sudo sed -i -e "/^proxy=.*/d" /etc/yum.conf;
                echo "proxy=$proxy" | sudo tee -a /etc/yum.conf;
            fi
        ;;
    esac
}

