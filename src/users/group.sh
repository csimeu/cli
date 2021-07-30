#!/bin/bash

function group_usage()
{
    echo "Usage:"
    echo "    ${cmd//_/:} [options] <groupname>"
    echo ""
    echo "Arguments:"
    echo "  groupname                 Group name"
    echo ""
    echo "Options:"
    echo "  -h, --help              Display this help message"
    echo "      --gid               group ID"
    echo "      --user              Add user to groups"
    echo "  -f, --update            Update group if already exist"
    echo ""
    echo "Help:"
    echo "  The ${cmd//_/:} Add or update group"
    echo ""
    echo "  $0 ${cmd//_/:} admin"
    echo "  $0 ${cmd//_/:} admin --gid=2000 --user=userdemo --user=admindemo"
    echo ""
}

# Reads arguments options
function parse_group_arguments()
{
  # if [ $# -ne 0 ]; then
    local TEMP=`getopt -o p::,h,f --long help,force,gid::,group::,user:: -n "$0" -- "$@"`
    
	eval set -- "$TEMP"
    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            -h|--help) HELP=1 ; shift 1 ;;
            -f|--force) FORCE=1 ; shift 1 ;;
            --uid) uid="-u ${2}" ; shift 2 ;;
            --gid) gid="-g ${2}" ; shift 2 ;;
            --home) home="-d ${2}" ; shift 2 ;;
            --password) password="${2}" ; shift 2 ;;
            --group) groups+="${2} "; shift 2 ;;
            --user) users+="${2} "; shift 2 ;;
            --) shift ; break ;;
            *) echo "Internal error! $1" ; exit 1 ;;
        esac
    done

    shift $(expr $OPTIND - 1 )
    _parameters=$@
    
    if [[ "1" == $HELP ]]; 
    then
        group_usage
        exit 0
    fi
}

# 
function group_add() 
{
    set -e
    local HELP=0
    local FORCE=0
    local uid=
    local gid=
    local users=
    local groups=

    local _parameters=
    parse_group_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    groupname=$1


    if [[ -z "$groupname" ]]; 
    then
        echo "Commande invalide!"
        echo "    Required a groupname"
        user_usage
        exit 1
    fi

    
    if [ ! $(getent group ${groupname}) ]; then 
        sudo groupadd $gid ${groupname};
    else 
        if [[ "1" == "$FORCE" && -n "$gid" ]]; then sudo groupmod $gid ${groupname}; fi
    fi

    for user in $users
    do  
        # checks if user exit
        if  $(getent user ${user})
        then
            usermod -aG $groupname ${user}
        else
            echo "Not found user '$user'"
        fi
    done

}

# 
function group_update() 
{
    set -e
    local HELP=0
    local FORCE=0
    local uid=
    local gid=
    local users=
    local groups=

    local _parameters=
    parse_group_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    groupname=$1


    if [[ -z "$groupname" ]]; 
    then
        echo "Commande invalide!"
        echo "    Required a groupname"
        user_usage
        exit 1
    fi

    
    if [ ! $(getent group ${groupname}) ]; then 
        if [ "1" == "$FORCE" ]; then sudo groupadd $gid ${groupname}; else echo "Group '$groupname' not found! "; exit 1; fi
    else 
        if [ -n "$gid" ]; then sudo groupadd $gid ${groupname}; fi
    fi

    for user in $users
    do  
        # checks if user exit
        if  $(getent user ${user})
        then
            usermod -aG $groupname ${user}
        else
            echo "  >> Not found user '$user'"
        fi
    done
}
    
    