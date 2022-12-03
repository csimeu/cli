#!/bin/bash

# Install alertmanager


function alertmanager_install() 
{
    set -e
    local appName=alertmanager
    local version=
    local data=/var/lib/$appName
    local port=
    
    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    # data=${data:-"$1"}
    # data=${data%"/"} 
    # INSTALL_DIR=${INSTALL_DIR%"/"} 

    case `plateform_name` in 
        alpine)  
            install alertmanager
            exit 0;
        ;;
    esac

  install alertmanager
}


