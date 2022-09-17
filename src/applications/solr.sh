#!/bin/bash

# Install solr


function solr_install() 
{
    set -e
    local appName=solr

    local FORCE=0
    local IS_DEFAULT=0
    local version=$SORL_DEFAULT_VERSION
    local port=8983
    local data_dir=/var/lib/solr
    local INSTALL_DIR=/usr/share

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    case "$version" in
        "8") version=8.11.1 ;;
        "7") version=7.7.3 ;;
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
    # data_dir=${data_dir%"/"} 
    # INSTALL_DIR=${INSTALL_DIR%"/"}

    # Install Solr
    # ARG version=7.4.0
    # ARG SOLR_PORT=8983
    # ENV SOLR_DIR=${APP_DIR}/solr

    # rm -rf solr-"$version".tgz install_solr_service.sh

    # echo 2
    if [ ! -f /tmp/releases/solr-$version.tgz ]
    then 
        curl -fSL https://archive.apache.org/dist/lucene/solr/$version/solr-$version.tgz -o /tmp/releases/solr-$version.tgz
    fi

    # 
    cd /tmp/releases
    # sudo mkdir -p ${data_dir} $INSTALL_DIR
    tar -xzf solr-"$version".tgz solr-"$version"/bin/install_solr_service.sh --strip-components=2

    sudo ./install_solr_service.sh solr-"$version".tgz -i "${INSTALL_DIR}" -d "$data_dir" -p "${port}" 
    # if [ -n "$data_dir" ]; then 
    #     ./install_solr_service.sh solr-"$version".tgz -i "${INSTALL_DIR}" -d "$data_dir" -p "${port}" 
    # else
    #     ./install_solr_service.sh solr-"$version".tgz -i "${INSTALL_DIR}" -p "${port}" 
    # fi
      
    # echo " ./install_solr_service.sh solr-$version.tgz -i ${INSTALL_DIR} -d $data -p ${port} "
    
    if [ ! -f /tmp/releases/jts-core-1.16.1.jar ]; then 
        curl -fSL https://github.com/locationtech/jts/releases/download/jts-1.16.1/jts-core-1.16.1.jar -o /tmp/releases/jts-core-1.16.1.jar
        # wget https://github.com/locationtech/jts/releases/download/jts-1.16.1/jts-core-1.16.1.jar
    fi

    sudo cp -f /tmp/releases/jts-core-1.16.1.jar $INSTALL_DIR/solr-$version/server/solr-webapp/webapp/WEB-INF/lib/
    
    # cd $INSTALL_DIR/solr/server/solr-webapp/webapp/WEB-INF/lib && \
    # wget http://central.maven.org/maven2/org/locationtech/jts/jts-core/1.15.0/jts-core-1.15.0.jar

    # && chown :"${GROUP_ADMIN}" -R /etc/default/ && chmod g+w -R /etc/default \
    # && usermod solr -g "${GROUP_ADMIN}" \
    # && systemctl enable solr 
    sudo chown solr:solr -R "${INSTALL_DIR}/solr-$version" ${data_dir}

    # if [[ -n "$ADMIN_USER" && $(getent passwd $ADMIN_USER)  ]]; then sudo usermod -aG solr $ADMIN_USER; fi

    # if [[ -n "$GROUP_ADMIN" ]]; then
    #     sudo usermod -g $GROUP_ADMIN solr;
    # fi
    echo ">> Installed applications '$appName' "
}


# if [ ! $# -eq 0 ]; 
# then
#   install_solr $@
# fi
