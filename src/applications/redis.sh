#!/bin/bash

redis_install() {
    local appName=redis
    case `plateform` in 
        redhat)
            case $OS_VERSION in 
                6|7)
                    if [ ! -f /etc/yum.repos.d/remi.repo ]; then
                        install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
                    fi
                    sudo yum-config-manager --enable remi 
                ;;
                *)
                    # 
                ;;
            esac
        ;;
    esac

    install redis
    sudo sed -i -e 's/^bind .*/bind 0.0.0.0/' /etc/redis/redis.conf;

    if [[ -n "$ADMIN_USER" && $(getent passwd $ADMIN_USER)  ]]; then sudo usermod -aG redis $ADMIN_USER; fi
    echo ">> Installed applications '$appName' "
}


redis_start(){
    local config_file=${1:-"/etc/redis/redis.conf"}
    cmdline="/usr/bin/redis-server $config_file --supervised systemd --daemonize no"
    if [ "$(id -u -n)" == "redis" ]; then 
        $cmdline &
    else 
        sudo -u redis $cmdline &
    fi
}

