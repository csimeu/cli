#!/bin/bash



fuseki_install() {
    
    local _name=fuseki
    local FORCE=0
    local IS_DEFAULT=0
    local version=$FUSEKI_DEFAULT_VERSION
    local data=/var/lib
    local name=
    local catalina_home=
    
    local _parameters=
    read_application_arguments $@
    if [ -n "$_parameters" ]; then set $_parameters; fi

    local repo_url=downloads.apache.org
    case "$version" in
        "4") version=4.1.0;;
        "3") version=3.14.0; repo_url=archive.apache.org/dist ;;
        *)
        ;;
    esac

    local givenname=$name
    name="$_name-$version"

    if [ '1' == $FORCE ]; then 
        sudo rm -rf $INSTALL_DIR/$name
    fi
    
    if [ -d $INSTALL_DIR/$name ]
    then 
        echo "Application already installed into  $INSTALL_DIR/$name"
        exit 0
    fi


    # name=${name//./-/}



    # local name=fuseki
    # local data=
    # local version=3.14.0
    # local install_dir=/usr/share
    # local catalina_home=${CATALINA_HOME:-"/usr/share/tomcat"}


    if [ ! -f /tmp/apache-jena-fuseki-$version.tar.gz ];
    then 
        echo "https://$repo_url/jena/binaries/apache-jena-fuseki-$version.tar.gz -o /tmp/apache-jena-fuseki-$version.tar.gz"
        curl -fSL https://$repo_url/jena/binaries/apache-jena-fuseki-$version.tar.gz -o /tmp/apache-jena-fuseki-$version.tar.gz
        # curl -fSL https://archive.apache.org/dist/jena/binaries/apache-jena-fuseki-$version.tar.gz -o /tmp/apache-jena-fuseki-$version.tar.gz
    fi
    
    # sudo cp -f /tmp/fcrepo-webapp-$version.war ${catalina_home}/webapps/${name}.war

    # curl -fSL https://archive.apache.org/dist/jena/binaries/apache-jena-fuseki-$version.tar.gz -o apache-jena-fuseki-$version.tar.gz
    sudo tar -xzf /tmp/apache-jena-fuseki-$version.tar.gz -C $INSTALL_DIR
    sudo mv $INSTALL_DIR/apache-jena-fuseki-${version} $INSTALL_DIR/$name


    if [ '1' == $IS_DEFAULT ]; then 
        catalina_home=/usr/share/tomcat; 
        givename=$_name
        sudo rm -rf /usr/share/$_name
        sudo ln -s $INSTALL_DIR/$name /usr/share/$_name
    fi

    if [ -d $catalina_home/webapps ]; then
        if [ '1' == $FORCE ]; then sudo rm -f ${catalina_home}/webapps/${name}.war ; fi
        
        if [ ! -f ${catalina_home}/webapps/${name}.war ]
        then 
            sudo cp -f "$INSTALL_DIR/${name}/fuseki.war" ${catalina_home}/webapps/${givename:-$name}.war
        fi

    fi

    


    # sudo cp -f "$INSTALL_DIR/fuseki-${version}/fuseki.war" "${catalina_home}/webapps/$name.war"


    # mkdir -p /etc/$name/configuration
    # chown tomcat:tomcat -R /etc/$name
    echo ">> Installed application '$_name' (version = $version) in $INSTALL_DIR/${name}"
}
