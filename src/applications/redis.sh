#!/bin/bash

redis_install() {
    local appName=redis
    case `plateform` in 
        redhat)
            if [ ! -f /etc/yum.repos.d/remi.repo ]; then
                sudo yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
            fi
            sudo yum-config-manager --enable remi 
        ;;
    esac

    install -y  redis
    
    echo ">> Installed applications '$appName' "
}

