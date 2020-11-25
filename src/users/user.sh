#!/bin/bash

function user_usage()
{
    echo "Usage:"
    echo "    ${cmd//_/:} [options] <username>"
    echo ""
    echo "Arguments:"
    echo "  username                 Username"
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
function parse_user_arguments()
{
  # if [ $# -ne 0 ]; then
    local TEMP=`getopt -o p:: --long help::,uid::,gid::,home::,group:: -n "$0" -- "$@"`
    
	eval set -- "$TEMP"
    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            --uid) uid="-u ${2}" ; shift 2 ;;
            --gid) gid="-g ${2}" ; shift 2 ;;
            --home) home="-d ${2}" ; shift 2 ;;
            --group) groups+="${2} "; shift 2 ;;
            --) shift ; break ;;
            *) echo "Internal error! $1" ; exit 1 ;;
        esac
    done

    shift $(expr $OPTIND - 1 )
    _parameters=$@
}

# 
function useradd() 
{
    set -e
    local help=0
    local home=
    local uid=
    local gid=
    local groups=

    local _parameters=
    parse_user_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    username=$1

    if [[ -z "$username" ]]; 
    then
        echo "Commande invalide!"
        echo "    Required username"
        user_usage
        exit 1
    fi

    
    if [ ! $(getent group ${username}) ]; then 
        groupadd $gid ${username};
    # else
    #     groupmod -g $USER_UID ${username};
    fi


    if ! getent passwd ${username} > /dev/null 2>&1; then
        useradd $uid -g ${username} $home ${username};
    else
        usermod $uid -g ${username} ${username};
    fi
    
    for group in $groups
    do  
        # checks if user exit
        if ! $(getent group ${group})
        then
            groupadd $group
            # echo "Group '$group' does not exist: group created!"                 
        fi
        usermod -aG $group ${username}
    done

#     for user in $_USERS
#     do  
#     done

}
    
    
# # Configuration des comptes administrateurs

# # if [ -n "${ROOT_PASSWORD}" ];
# # then
# #     echo "${ROOT_PASSWORD}" | passwd "root" --stdin ; 
# # fi ;

# # # Sets user primary group
# # if [ ! $(getent group ${GROUP_ADMIN}) ]; 
# # then 
# #     groupadd ${GROUP_ADMIN}; 
# # fi 

# # usermod  -aG ${GROUP_ADMIN} root

# # if [ -n "$GROUP_ADMIN_UID" ]; 
# # then 
# #     groupmod -g $GROUP_ADMIN_UID ${GROUP_ADMIN}; 
# # fi


# _USER=${1}
# _USER_UID=${2}

# #
# # Create user account if not exist


# # ssh
# if ! getent passwd ${_USER} > /dev/null 2>&1; 
# then
        
#     if [ "$_USER" == "${GROUP_ADMIN}" ]; 
#     then
#         useradd -g ${_USER} ${_USER};
#     else
#         useradd ${_USER};
#     fi

    
# fi

# usermod $_USER -aG ${GROUP_ADMIN}

# if [ -n "$_USER_UID" ];
# then
#     usermod -u $_USER_UID ${_USER};
# fi
		
# # Sets user's password
# # if [ -n "${USER_PASSWORD}" ];
# # then 
# #     echo "${USER_PASSWORD}" | passwd "${_USER}" --stdin ;
# # fi;


# # ssh
# if getent passwd ${_USER} > /dev/null 2>&1; 
# then
#     if [[ -d $CONFIG_DIR/.${_USER}/.ssh ]]
#     then
#         mv $CONFIG_DIR/.${_USER}/.ssh /home/${_USER}/.ssh
#         chmod 600 /home/${_USER}/.ssh/*
#         chmod 700 /home/${_USER}/.ssh
#         if [ -f /home/${_USER}/.ssh/config ]; then chmod 644 /home/${_USER}/.ssh/config; fi
#     fi
    
#     if [ -f $CONFIG_DIR/.${_USER}/.gitconfig ]; then 
#         mv $CONFIG_DIR/.${_USER}/.gitconfig /home/${_USER}/;
#     fi

#     if [[ -d $CONFIG_DIR/.${_USER} ]]
#     then
#         rm -rf $CONFIG_DIR/.${_USER}
#     fi&_2(2Sotl/z!
# fi

# chown ${_USER}:${_USER} -R /home/${_USER}/