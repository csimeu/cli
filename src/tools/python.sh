#!/bin/bash

# Install solr


# # Reads arguments options
# function parse_python_arguments()
# {
#   # if [ $# -ne 0 ]; then
#     local TEMP=`getopt -o p:: --long data::,version::,port::,config-file:: -n "$0" -- "$@"`
    
# 	eval set -- "$TEMP"
#     # extract options and their arguments into variables.
#     while true ; do
#         case "$1" in
#             --install-dir) INSTALL_DIR=${2:-"$INSTALL_DIR"} ; shift 2 ;;
#             --data) data=${2%"/"} ; shift 2 ;;
#             --file-config) config_file=${2:-"$config_file"}; shift 2 ;;
#             --version) version=${2:-"$version"}; shift 2 ;;
#             --port) port=${2:-"$port"}; shift 2 ;;
#             --users-config) users_config=${2:-"$users_config"}; shift 2 ;;
#             # --db-name) DB_NAME=${2:-"$DB_NAME"}; shift 2 ;;
#             # --db-user) DB_USER=${2:-"$DB_USER"}; shift 2 ;;
#             # --db-password) DB_PASSWORD=${2:-"$DB_PASSWORD"}; shift 2 ;;
#             # --db-host) DB_HOST=${2:-"$DB_HOST"}; shift 2 ;;
#             # --port) port=${2:-"$port"}; shift 2 ;;
#             --) shift ; break ;;
#             *) echo "Internal error! $1" ; exit 1 ;;
#         esac
#     done

#     shift $(expr $OPTIND - 1 )
#     _parameters=$@
    
#   # fi
# }

function python_install_requirements() 
{
    set -e
    requirements=${1:-"requirements.txt"}
    local _USE_PROXY
    if [[ -n "$http_proxy" ]]; then
        _USE_PROXY="--proxy $http_proxy";
    fi

    if [ -f $requirements ]; then
        pip3 install ${PIP_USE_PROXY} $requirements
    fi
}


function pip_install() 
{
    set -e
    local _USE_PROXY
    if [[ -n "$http_proxy" ]]; then
        _USE_PROXY="--proxy $http_proxy";
    fi

    sudo pip3 install ${PIP_USE_PROXY} $@
}


# if [ ! $# -eq 0 ]; 
# then
#   install_solr $@
# fi
