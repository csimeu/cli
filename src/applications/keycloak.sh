#!/bin/bash

function keycloak_install() 
{
    set -e

    local appName=keycloak

    local FORCE=0
    local IS_DEFAULT=0
    local version=$KEYCLOAK_DEFAULT_VERSION
    # local data=/var/lib
    local name=
    # local catalina_home=
    # local fcrepo_config=
    # local file_config=
    # echo $@


    # local version=8.0.1
    # local name=keycloak
    # local INSTALL_DIR=/usr/share
    # local port_offset=100

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi



    case "$version" in
        "8") version=8.0.2;;
        14|13|12|11|10) version=$version.0.0;;
        *)
        ;;
    esac

    name="$appName-$version"
    local KEYCLOAK_HOME=${INSTALL_DIR}/$name


    
    if [ -d $INSTALL_DIR/$name ]
    then 
        if [ '0' == $FORCE ]; then 
            # sudo rm -rf $INSTALL_DIR/$name
            echo "Application already installed into  $INSTALL_DIR/$name"
            exit 0
        fi
    fi


    # _PORT=${3:-"8088"}

    ## Install keycloak
    # https://blog.ineat-conseil.fr/2017/11/securisez-vos-apis-spring-avec-keycloak-1-installation-de-keycloak/
    # https://medium.com/@hasnat.saeed/setup-keycloak-server-on-ubuntu-18-04-ed8c7c79a2d9
    mkdir -p $KEYCLOAK_HOME;
    
    if [ ! -f /tmp/releases/keycloak-${version}.tar.gz ];
    then
        echo "https://downloads.jboss.org/keycloak/${version}/keycloak-${version}.tar.gz"
        curl -fSL https://downloads.jboss.org/keycloak/${version}/keycloak-${version}.tar.gz -o /tmp/releases/keycloak-${version}.tar.gz;
    fi
    
    tar -xzf /tmp/releases/keycloak-${version}.tar.gz -C $KEYCLOAK_HOME --strip-components=1;

    if ! getent passwd $appName > /dev/null 2>&1; then
        sudo groupadd --system $appName
        sudo useradd -d /var/www -r -s /bin/false -g $appName $appName
    fi
    
    chown -R $appName:$appName $KEYCLOAK_HOME;
    chmod g+w -R $KEYCLOAK_HOME
    chmod o+x $KEYCLOAK_HOME/bin/


    mkdir -p $KEYCLOAK_HOME/modules/org/postgresql/main
    if [ ! -f $KEYCLOAK_HOME/modules/org/postgresql/main/postgresql-42.2.5.jar ]
    then
        if [ ! -f /tmp/releases/postgresql-42.2.5.jar ]; then
            curl -fSL https://jdbc.postgresql.org/download/postgresql-42.2.5.jar -o /tmp/releases/postgresql-42.2.5.jar
        fi
        sudo cp /tmp/releases/postgresql-42.2.5.jar $KEYCLOAK_HOME/modules/org/postgresql/main/
    fi

    if [ ! -f $KEYCLOAK_HOME/modules/org/postgresql/main/module.xml ]
    then
        sudo cat > $KEYCLOAK_HOME/modules/org/postgresql/main/module.xml <<  EOF
<?xml version="1.0" ?>
<module xmlns="urn:jboss:module:1.3" name="org.postgresql">
    <resources>
        <resource-root path="postgresql-42.2.5.jar"/>
    </resources>
    <dependencies>
        <module name="javax.api"/>
        <module name="javax.transaction.api"/>
    </dependencies>
</module>'
EOF
    fi

    # curl -fSL https://jdbc.postgresql.org/download/postgresql-42.2.5.jar -o $KEYCLOAK_HOME/postgresql-42.2.5.jar
    # $KEYCLOAK_HOME/bin/jboss-cli.sh -c "module add --name=org.postgresql  --dependencies=javax.api,javax.transaction.api --resources=postgresql-42.2.5.jar"

    mkdir -p $KEYCLOAK_HOME/modules/org/mysql/main
    if [ ! -f $KEYCLOAK_HOME/modules/org/mysql/main/mysql-connector-java-5.1.47.jar ]
    then
        if [ ! -f /tmp/releases/mysql-connector-java-5.1.47.tar.gz ]; then
            curl -fSL https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.47.tar.gz -o /tmp/releases/mysql-connector-java-5.1.47.tar.gz
        fi
        tar -xzf /tmp/releases/mysql-connector-java-5.1.47.tar.gz mysql-connector-java-5.1.47/mysql-connector-java-5.1.47.jar --strip-components=1
        sudo mv mysql-connector-java-5.1.47.jar $KEYCLOAK_HOME/modules/org/mysql/main/
    fi

    # curl -fSL https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.47.tar.gz -o /tmp/releases/mysql-connector-java-5.1.47.tar.gz
    # tar -xzf /tmp/releases/mysql-connector-java-5.1.47.tar.gz mysql-connector-java-5.1.47/mysql-connector-java-5.1.47.jar --strip-components=1
    # cp -f mysql-connector-java-5.1.47.jar $KEYCLOAK_HOME
    # # $KEYCLOAK_HOME/bin/jboss-cli.sh -c "module add --name=org.mysql  --dependencies=javax.api,javax.transaction.api --resources=mysql-connector-java-5.1.47.jar"


    cp -f $KEYCLOAK_HOME/docs/contrib/scripts/systemd/launch.sh $KEYCLOAK_HOME/bin/
    sed -i -e "s|/opt/wildfly|$KEYCLOAK_HOME|" $KEYCLOAK_HOME/bin/launch.sh;
    if [ -n "$port_offset" ]; then
        sed -i -e "s|standalone.sh.*|standalone.sh -c \$2 -b \$3 -Djboss.socket.binding.port-offset=$port_offset |" $KEYCLOAK_HOME/bin/launch.sh;
    fi

#  $WILDFLY_MODE $WILDFLY_CONFIG $WILDFLY_BIND
# /usr/share/keycloak/bin/standalone.sh -c standalone.xml -b 0.0.0.0 -Djboss.socket.binding.port-offset=100
    sudo mkdir -p /etc/$appName
    if [ ! -f /etc/$appName/$name.conf ];
    then 
        sudo cp -f $KEYCLOAK_HOME/docs/contrib/scripts/systemd/wildfly.conf /etc/$appName/$name.conf;
        
    fi
    sudo chown -R keycloak:keycloak /etc/keycloak


    if [[ "6" != $OS_VERSION ]]; then
        sudo cat > /etc/systemd/system/$name.service << EOF
[Unit]
Description=The Keycloak Server $version
After=syslog.target network.target tomcat.target
Before=httpd.service

[Service]
Environment=LAUNCH_JBOSS_IN_BACKGROUND=1
EnvironmentFile=/etc/$appName/$name.conf
User=keycloak
LimitNOFILE=102642
PIDFile=$KEYCLOAK_HOME/keycloak.pid
ExecStart=$KEYCLOAK_HOME/bin/launch.sh \$WILDFLY_MODE \$WILDFLY_CONFIG \$WILDFLY_BIND
StandardOutput=null

[Install]
WantedBy=multi-user.target
EOF
        if [ '1' == $IS_DEFAULT ]; then 
            sudo rm -f /etc/systemd/system/$appName.service
            sudo cp /etc/systemd/system/$name.service /etc/systemd/system/$appName.service
        fi

        # sudo systemctl daemon-reload
    fi

    if [ '1' == $IS_DEFAULT ]; then 
        sudo rm -rf /usr/share/$appName
        sudo ln -s $KEYCLOAK_HOME /usr/share/$appName
    fi

    sudo rm -f $KEYCLOAK_HOME/standalone/configuration/keycloak-add-user.json
    $KEYCLOAK_HOME/bin/add-user-keycloak.sh -u admin -p admin -r master
    
    echo ">> Installed application '$appName' (version = $version) in $INSTALL_DIR/${name}"
}
