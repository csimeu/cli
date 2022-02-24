#!/bin/bash

# Reads arguments options
function parse_elk_arguments()
{
    local TEMP=`getopt -o p:: --long version::,beats:: -n "$0" -- "$@"`
    
	eval set -- "$TEMP"
    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            --version) version=${2:-"$version"}; shift 2 ;;
            # --tomcat-config) tomcat_config=${2:-"$tomcat_config"}; shift 2 ;;
            --users-config) users_config=${2:-"$users_config"}; shift 2 ;;
            # --db-name) DB_NAME=${2:-"$DB_NAME"}; shift 2 ;;
            # --db-user) DB_USER=${2:-"$DB_USER"}; shift 2 ;;
            # --db-password) DB_PASSWORD=${2:-"$DB_PASSWORD"}; shift 2 ;;
            # --db-host) DB_HOST=${2:-"$DB_HOST"}; shift 2 ;;
            # --db-port) DB_PORT=${2:-"$DB_PORT"}; shift 2 ;;
            --) shift ; break ;;
            *) echo "Internal error! $1" ; exit 1 ;;
        esac
    done

    shift $(expr $OPTIND - 1 )
    _parameters=$@
    
  # fi
}

elk_import_repolist() {
    # echo $(plateform)
    case `plateform` in 
        debian)
            # echo "debian"
            if [[ ! -f /etc/apt/sources.list.d/elastic-$version.x.list ]]; then
                wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
                echo "deb https://artifacts.elastic.co/packages/$version.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-$version.x.list
                sudo apt-get -y update
            fi
            ;;
        redhat)
            # echo "redhat"
            if [[ ! -f /etc/yum.repos.d/elasticsearch-${version}.x.repo ]]; then
                sudo cat > /etc/yum.repos.d/elasticsearch-${version}.x.repo << EOF
[elasticsearch-${version}.x]
name=Elasticsearch repository for ${version}.x packages
baseurl=https://artifacts.elastic.co/packages/${version}.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
            # sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
        fi
        ;;
    esac

    # # if [[ is_debian && ! -f /etc/apt/sources.list.d/elastic-$version.x.list ]]; then
    # #     wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
    # #     echo "deb https://artifacts.elastic.co/packages/$version.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-$version.x.list
    # #     sudo apt-get -y update
    # # fi
    # # snake_to_camel test
    # if [[  `is_redhat`  ]]; then
    #     # echo $(is_debian)
    #     echo $(awk -F= '/^ID_LIKE=/{print $2}' /etc/os-release)
    # # fi
    # fi
}

# elk_import_deb() {
#     if [ ! -f /etc/apt/sources.list.d/elastic-$version.x.list ]
#     then 
#         wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
#         echo "deb https://artifacts.elastic.co/packages/$version.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-$version.x.list
#         sudo apt-get -y update
#     fi
# }

elk_install_beats() {
    elk_import_repolist
    install -y filebeat auditbeat metricbeat packetbeat heartbeat-elastic
}

elk_install() {
    local version=7
    local _parameters=
    parse_elk_arguments $@ 
    
    elk_import_repolist
    install -y elasticsearch kibana
}

elasticsearch_install() {
    local version=7
    local _parameters=
    parse_elk_arguments $@ 
    
    elk_import_repolist
    install -y elasticsearch

    if [[ -n "$ADMIN_USER" && $(getent passwd $ADMIN_USER)  ]]; then sudo usermod -aG elasticsearch $ADMIN_USER; fi
    
    sed -i -e "s/^\#\# -Xms.*$/-Xms128m/" /etc/elasticsearch/jvm.options
    sed -i -e "s/^## -Xmx.*$/-Xmx128m/" /etc/elasticsearch/jvm.options
}

kibana_install() {
    local version=7
    local _parameters=
    parse_elk_arguments $@ 
    
    elk_import_repolist
    install -y kibana
}

## detect if a script is being sourced or not
# if [[ $_ == $0 ]] 
# then
# 	elk_install "$@"
# fi





