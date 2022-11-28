#!/bin/bash

# Install fedora commons repository



function java_install() 
{
    set -e
    local FORCE=0
    local IS_DEFAULT=0
    local version=11
    # echo $@

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    plateform=`plateform`

    case $plateform in 
        alpine)  install openjdk${version:-11} ;; 
        redhat)
			if [[ `plateform_version` =~ 6 ]]; then 
                install java-1.8.0-openjdk-devel; 
            else 
                install java-${version:-11}-openjdk-devel; 
            fi
            ;;
        # debian)
        #     install default-jdk gnupg2
        # ;;
        debian|ubuntu)
            install openjdk-${version:-11}-jdk gnupg2
        ;;
        *)
            echo ">> Noy implemented script for plateform: $plateform"
        ;;
    esac

    echo "export JAVA_HOME=$(readlink -f $(which java) | sed -e "s/\/bin\/java//")"  >> /etc/profile.d/java.sh
    source /etc/profile.d/java.sh
}


