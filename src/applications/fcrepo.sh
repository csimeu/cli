#!/bin/bash

# Install fedora commons repository



function fcrepo_install() 
{
    set -e
    local FORCE=0
    local IS_DEFAULT=0
    local version=$FCREPO_DEFAULT_VERSION
    local data_dir=
    local name=
    local catalina_home=$CATALINA_HOME
    local fcrepo_config=
    local file_config=
    # echo $@

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    name=${name:-"fcrepo$version"}
    name=${name//./-/}

    if [ '1' == $IS_DEFAULT ]; then 
        catalina_home=/usr/share/tomcat; 
        name=fcrepo
    fi

    if [ -z $catalina_home ]; then
        echo " --catalina_home value is required"
        exit 1
    fi

    if [ '1' == $FORCE ]; then 
        sudo rm -f ${catalina_home}/webapps/${name}.war
    fi

    if [ -f ${catalina_home}/webapps/${name}.war ]
    then 
        echo "Current file already exist: ${catalina_home}/webapps/${name}.war"
        exit 0
    fi


    # https://github.com/fcrepo/fcrepo/releases/download/fcrepo-5.1.0/fcrepo-webapp-5.1.0.war
    # 
    # https://github.com/fcrepo4/fcrepo4/releases/download/fcrepo-4.7.5/fcrepo-webapp-4.7.5.war

    case "$version" in
        "4") version=4.7.5;;
        "5") version=5.1.1;;
        "6") version=6.1.1;;
        *)
        ;;
    esac
    
    
    if [ ! -f /tmp/releases/fcrepo-webapp-$version.war ];
    then 
        curl -fSL https://github.com/fcrepo/fcrepo/releases/download/fcrepo-$version/fcrepo-webapp-$version.war -o /tmp/releases/fcrepo-webapp-$version.war
    fi

    sudo cp -f /tmp/releases/fcrepo-webapp-$version.war ${catalina_home}/webapps/${name}.war

    # sudo curl -fSL https://github.com/fcrepo4-exts/fcrepo-webapp-plus/releases/download/fcrepo-webapp-plus-$version/fcrepo-webapp-plus-$fcrepo_config$version.war -o ${catalina_home}/webapps/${name}.war
    #
    local ModeshapeConfig=file-simple
    local JDBCConfig=

    if [ -z "$data_dir" ]; then
        data_dir="/var/lib/${name}"
    fi
    # ARG FCREPO_DIR=${APP_DIR}/fcrepo
    sudo mkdir -p $data_dir && sudo chown tomcat:tomcat -R $data_dir
    if [ -f $catalina_home/conf/tomcat.sh ]; then 
        sudo sed -i -e "/^JAVA_OPTS=\"-Dfcrepo.*/d" $catalina_home/conf/tomcat.sh
        sudo echo 'JAVA_OPTS="-Dfcrepo.modeshape.configuration=classpath:/config/'$ModeshapeConfig'/repository.json '$JDBCConfig' -Dfcrepo.home='$data_dir' -Dfcrepo.audit.container=/audit $JAVA_OPTS"' >> $catalina_home/conf/tomcat.sh
    fi

    # sudo mv fcrepo-$fcrepo_config$version.war "${catalina_home}/webapps/${name}.war"

    # sudo echo "export JAVA_OPTS=\"\$JAVA_OPTS -Dfcrepo.modeshape.configuration=classpath:/config/$ModeshapeConfig/repository.json $JDBCConfig -Dfcrepo.home=$data -Dfcrepo.audit.container=/audit\"" > /etc/profile.d/fcrepo.sh
    # source /etc/profile.d/fcrepo.sh

    echo ">> Installed application '$name' (version = $version) in ${catalina_home}/webapps/${name}.war"
}

## detect if a script is being sourced or not
# if [[ $_ == $0 ]] 
# then
#   fcrepo_install $@
# fi

