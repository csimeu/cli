#!/bin/bash

# Install fedora commons repository



function java_install() 
{
    set -e
    local FORCE=0
    local IS_DEFAULT=0
    local version=
    # echo $@

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    plateform=`plateform`

    case $plateform in 
        redhat)
			if [[ `plateform_version` =~ 6 ]]; then 
                install -y java-1.8.0-openjdk-devel; 
            else 
                install -y java-11-openjdk-devel; 
            fi
            ;;
        debian)
            install -y default-jdk
        ;;
        *)
            echo ">> Noy implemented script for plateform: $plateform"
        ;;
    esac
}


