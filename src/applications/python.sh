#!/bin/bash

function python_install() 
{
    set -e
    local FORCE=0
    local IS_DEFAULT=0
    local version=3
    # echo $@

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    plateform=`plateform`

    case $plateform in 
        alpine)
            install python$version python$version-dev py$version-pip
            # if [[ "$version" == "2" ]];
            # then
            #     install python2 python2-dev py2-pip
            # else
            #     install python3 python3-dev py3-pip
            # fi
        ;;
        redhat)
            if [[ "$version" == "2" ]];
            then
                install python python-dev python-pip
            else
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
            fi
            ;;
        debian|ubuntu)
            install -qq python$version-pip python$version-dev
        ;;
        *)
            echo ">> Noy implemented script for plateform: $plateform"
            exit 1;
        ;;
    esac

    if [[ -f /usr/bin/python$version ]]; then
        execute rm -f /usr/bin/python && execute ln -s python$version /usr/bin/python ;
    fi
    
    pip_install --upgrade pip;
    pip_install virtualenv

}


