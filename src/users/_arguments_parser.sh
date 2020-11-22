#!/bin/bash

# Reads arguments options
function users_arguments_parser()
{
  # if [ $# -ne 0 ]; then
    TEMP=`getopt -o e::p::u::g:: --long env::,path::,user::,users::,group::groups:: -n "$0" -- "$@"`
    eval set -- "$TEMP"
    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            -h|--help) _HELP=1 ; shift 1 ;;
            -u|--user) _USER=${2:-"$_USER"}; _USERS+="${_USER} ";  shift 2 ;;
            --users) _USERS+="${2} ";  shift 2 ;;
            -g|--group) _GROUP=${2:-"$_GROUP"}; _GROUPS+="${_GROUP} ";  shift 2 ;;
            --groups) _GROUPS+="${2} ";  shift 2 ;;
            -p|--path) _PATH=${2:-"$_PATH"} ;  shift 2 ;;
            --) shift ; break ;;
            *) echo "Internal error! $1" ; exit 1 ;;
        esac
    done

    shift $(expr $OPTIND - 1 )
    _parameters=$@
    
  # fi
}
