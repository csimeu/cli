#!/bin/bash

# Install solr


# # Reads arguments options
# function parse_solr_arguments()
# {
#   # if [ $# -ne 0 ]; then
#     local TEMP=`getopt -o p:: --long data::,version::,port::,config-file:: -n "$0" -- "$@"`
    
# 	eval set -- "$TEMP"
#     # extract options and their arguments into variables.
#     while true ; do
#         case "$1" in
#             --install-dir) INSTALL_DIR=${2:-"$INSTALL_DIR"} ; shift 2 ;;
#             --data) data=${2%"/"} ; shift 2 ;;
#             --file-config) config_file=${2:-"$config_file"}; shift 2 ;;
#             --version) version=${2:-"$version"}; shift 2 ;;
#             --port) port=${2:-"$port"}; shift 2 ;;
#             --users-config) users_config=${2:-"$users_config"}; shift 2 ;;
#             # --db-name) DB_NAME=${2:-"$DB_NAME"}; shift 2 ;;
#             # --db-user) DB_USER=${2:-"$DB_USER"}; shift 2 ;;
#             # --db-password) DB_PASSWORD=${2:-"$DB_PASSWORD"}; shift 2 ;;
#             # --db-host) DB_HOST=${2:-"$DB_HOST"}; shift 2 ;;
#             # --port) port=${2:-"$port"}; shift 2 ;;
#             --) shift ; break ;;
#             *) echo "Internal error! $1" ; exit 1 ;;
#         esac
#     done

#     shift $(expr $OPTIND - 1 )
#     _parameters=$@
    
#   # fi
# }

function solr_install() 
{
    set -e
    local appName=solr

    local FORCE=0
    local IS_DEFAULT=0
    local version=$SORL_DEFAULT_VERSION
    local port=8983

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    case "$version" in
        "8") version=8.2.0 ;;
        "7") version=7.7.2 ;;
        *)
        ;;
    esac


    # local name="solr"
    # local version=8.2.0
    # local data=
    # local catalina_home=/usr/share/tomcat
    # local DB_PASSWORD=
    # local DB_HOST=localhost
    # local solr_config=
    # local file_config=
    # local INSTALL_DIR=/usr/share
    # # echo $@
    # local _parameters=
    # parse_solr_arguments $@ 
    # if [ -n "$_parameters" ]; then set $_parameters; fi

    # data=${data:-"$1"}
    data=${data%"/"} 
    INSTALL_DIR=${INSTALL_DIR%"/"}

    # Install Solr
    # ARG version=7.4.0
    # ARG SOLR_PORT=8983
    # ENV SOLR_DIR=${APP_DIR}/solr

    rm -rf solr-"$version".tgz install_solr_service.sh

    # echo 2
    if [ ! -f /tmp/releases/solr-$version.tgz ]
    then 
        curl -fSL https://archive.apache.org/dist/lucene/solr/$version/solr-$version.tgz -o /tmp/releases/solr-$version.tgz
    fi

    # 
    cd /tmp/releases
    mkdir -p ${data} $INSTALL_DIR
    tar -xzf solr-"$version".tgz solr-"$version"/bin/install_solr_service.sh --strip-components=2

    if [ -n "$data" ]; then 
        ./install_solr_service.sh solr-"$version".tgz -i "${INSTALL_DIR}" -d "$data" -p "${port}" 
    else
        ./install_solr_service.sh solr-"$version".tgz -i "${INSTALL_DIR}" -p "${port}" 
    fi
      
    # echo " ./install_solr_service.sh solr-$version.tgz -i ${INSTALL_DIR} -d $data -p ${port} "
    
    if [ ! -f /tmp/releases/jts-core-1.16.1.jar ]; then 
        curl -fSL https://github.com/locationtech/jts/releases/download/jts-1.16.1/jts-core-1.16.1.jar -o /tmp/releases/jts-core-1.16.1.jar
        # wget https://github.com/locationtech/jts/releases/download/jts-1.16.1/jts-core-1.16.1.jar
    fi

    cp -f /tmp/releases/jts-core-1.16.1.jar $INSTALL_DIR/solr-$version/server/solr-webapp/webapp/WEB-INF/lib/
    
    # cd $INSTALL_DIR/solr/server/solr-webapp/webapp/WEB-INF/lib && \
    # wget http://central.maven.org/maven2/org/locationtech/jts/jts-core/1.15.0/jts-core-1.15.0.jar

    # && chown :"${GROUP_ADMIN}" -R /etc/default/ && chmod g+w -R /etc/default \
    # && usermod solr -g "${GROUP_ADMIN}" \
    # && systemctl enable solr 
    sudo chown solr:solr -R "${INSTALL_DIR}/solr-$version" ${data}

    if [[ -n "$ADMIN_USER" && $(getent passwd $ADMIN_USER)  ]]; then sudo usermod -aG solr $ADMIN_USER; fi

    # if [[ -n "$GROUP_ADMIN" ]]; then
    #     sudo usermod -g $GROUP_ADMIN solr;
    # fi
    echo ">> Installed applications '$appName' "
}


# if [ ! $# -eq 0 ]; 
# then
#   install_solr $@
# fi
