#!/bin/bash

function add_user_usage()
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
    echo "      --password          User's password"
    echo "      --groups            Sets groups to user"
    echo "  -f, --update            Update user if already exist"
    echo ""
    echo "Help:"
    echo "  The ${cmd//_/:} Add or update user"
    echo ""
    echo "  $0 ${cmd//_/:} centos"
    echo "  $0 ${cmd//_/:} centos --uid=2000 --gid=2000 --password=pwd123 --group=wheel"
    echo ""
}

# # 
# function add_user() 
# {
#     set -e
#     local _HELP=0
#     local _USER=
#     local _USERS=
#     local _GROUP=
#     local _GROUPS=
#     local _PATH=
#     local _ENV=

#     local _parameters=
#     users_arguments_parser $@ 
#     if [ -n "$_parameters" ]; then set $_parameters; fi

#     if [[ -z "$_USERS" ]]; 
#     then
#         # echo "$_ORM_PATH:$_APP:$_entity_namespace!"
#         echo "Commande invalide!"
#         echo "    Required --user:              Group's name"
#         echo "    Required --users:             Groups's name"
#         add_users_usage
#         exit 1
#     fi

#     for user in $_USERS
#     do  
#         if ! grep -q "^${user}:" /etc/passwd
#         then
#             useradd $group
#             echo "User '$user' does not exist,  user created!"
#         fi
        
#         for group in $_GROUPS
#         do  
#             # checks if user exit
#             if ! grep -q "^${group}:" /etc/group
#             then
#                 groupadd $group
#                 echo "Group '$group' does not exist: group created!"                 
#             fi
#             usermod -aG $group ${user}
#         done
#     done

# }
    
    
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