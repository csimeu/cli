#!/bin/bash

function python_install() 
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
        alpine) install python3 python3-dev py3-pip
        ;;
        redhat)
            if [ "$(rpm -E %{rhel})" ==  "6" ]; then
                install python34 python34-libs python34-devel python34-pip;
            fi

            if [ "$(rpm -E %{rhel})" ==  "7" ]; then
                install python36 python36-libs python36-devel python36-pip;
                execute ln -s -f /usr/bin/pip3.6 /usr/bin/pip3;
            fi

            if [ "$(rpm -E %{rhel})" ==  "8" ]; then
                install python3 python3-pip;
            fi
            ;;
        debian)
            install -qq python3-pip python3-dev
        ;;
        *)
            echo ">> Noy implemented script for plateform: $plateform"
            exit 1;
        ;;
    esac
    
    pip_install --upgrade pip;
}


