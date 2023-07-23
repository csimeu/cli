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
        ;;
        redhat)
            if [[ "$version" == "2" ]];
            then
                install python python-dev python-pip
            else
				case $(rpm -E %{rhel}) in
					6)
                        install python34 python34-libs python34-devel python34-pip;
					;;
                    7)
                        install python36 python36-libs python36-devel python36-pip;
                        execute ln -s -f /usr/bin/pip3.6 /usr/bin/pip3;
                    ;;
					*)
                        install python3 python3-pip;
					;;
				esac
            fi
            ;;
        debian|ubuntu)
            if [[ "$version" == "2" ]];
            then
                install python python-dev
                curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output /tmp/get-pip.py
                sudo python2 /tmp/get-pip.py
            else
                install -qq python$version python$version-pip python$version-dev
            fi
        ;;
        *)
            echo ">> Noy implemented script for plateform: $plateform"
            exit 1;
        ;;
    esac

    if [[ -f /usr/bin/python$version ]]; then
        execute rm -f /usr/bin/python && execute ln -s python$version /usr/bin/python ;
    fi
    if [[ -f /usr/bin/pip$version ]]; then
        execute rm -f /usr/bin/pip && execute ln -s pip$version /usr/bin/pip ;
    fi
    
    pip_install --upgrade pip;
    pip_install virtualenv

}


