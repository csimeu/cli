#!/bin/bash

redis_install() {
    local appName=redis
    case `plateform` in 
        redhat)
            if [ ! -f /etc/yum.repos.d/remi.repo ]; then
                install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
            fi
            sudo yum-config-manager --enable remi 
        ;;
    esac

    install -y redis
    
    if [[ -n "$ADMIN_USER" && $(getent passwd $ADMIN_USER)  ]]; then sudo usermod -aG redis $ADMIN_USER; fi
    echo ">> Installed applications '$appName' "
}

