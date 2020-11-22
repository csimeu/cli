
#!/bin/bash
#


function add_groups_usage()
{
    echo "Usage:"
    echo "    ${cmd//_/:} [options] <console>"
    echo ""
    echo "Arguments:"
    echo "  console                 The console: default=bin/console"
    echo ""
    echo "Options:"
    echo "  -h, --help              Display this help message"
    echo "      --users             The path where saved orm mapping information"
    echo "      --groups            The path where saved orm mapping information"
    echo ""
    echo "Help:"
    echo "  The ${cmd//_/:} Ajouter des usagers dans des groupes"
    # echo ""
    # echo "  You have to limit generation of schema:"
    # echo ""
    # echo "  * To a single entity"
    # echo ""
    # echo "  $0 ${cmd//_/:} --name=User"
    # echo ""
    # echo "  * To a set of entities"
    # echo ""
    # echo "  $0 ${cmd//_/:} --name=User --name=Role"
    echo ""
}

# bin/cpm build:dal --orm-path=$APP_ORM_DIR --path=.
function add_groups() 
{
    set -e
    local _HELP=0
    local _USER=
    local _USERS=
    local _GROUP=
    local _GROUPS=
    local _PATH=
    local _ENV=

    local _parameters=
    users_arguments_parser $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    if [[ -z "$_GROUPS" ]]; 
    then
        # echo "$_ORM_PATH:$_APP:$_entity_namespace!"
        echo "Commande invalide!"
        echo "    Required --group:              Group's name"
        echo "    Required --groups:             Groups's name"
        add_groups_usage
        exit 1
    fi

    for group in $_GROUPS
    do  
        if ! grep -q "^${group}:" /etc/group
        then
            groupadd $group
            echo "Group '$group' does not exist: group will create!"
        fi
        
        for user in $_USERS
        do  
            # checks if user exit
            if grep -q "^${user}:" /etc/passwd
            then
                usermod -aG $group ${user}
            else
                echo "User '$user' does not exist"
            fi
        done
    done

}
    
    