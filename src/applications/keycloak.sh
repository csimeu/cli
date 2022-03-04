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
        17|16|15|14|13|12|11|10) version=$version.0.0;;
        *)
        ;;
    esac

    name="$appName-$version"
    local KEYCLOAK_HOME=${INSTALL_DIR}/$name

    if [ -d $KEYCLOAK_HOME ]
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
        echo "https://github.com/keycloak/keycloak/releases/download/${version}/keycloak-${version}.tar.gz"
        curl -fSL https://github.com/keycloak/keycloak/releases/download/${version}/keycloak-${version}.tar.gz -o /tmp/releases/keycloak-${version}.tar.gz;
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
</module>
EOF
        $KEYCLOAK_HOME/bin/jboss-cli.sh 'embed-server,/subsystem=datasources/jdbc-driver=postgresql:add(driver-name=postgresql,driver-module-name=org.postgresql,driver-xa-datasource-class-name=org.postgresql.xa.PGXADataSource)'
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
    
    if [[ -n "$ADMIN_USER" && $(getent passwd $ADMIN_USER)  ]]; then sudo usermod -aG keycloak $ADMIN_USER; fi


    if [[ "6" != $OS_VERSION ]]; then
        sudo cat > /etc/systemd/system/$name.service << EOF
[Unit]
Description=The Keycloak Server $version
After=syslog.target network.target
#Before=httpd.service

[Service]
Environment=LAUNCH_JBOSS_IN_BACKGROUND=1
EnvironmentFile=/etc/$appName/$name.conf
#User=keycloak
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

    # sudo rm -f $KEYCLOAK_HOME/standalone/configuration/keycloak-add-user.json
    # $KEYCLOAK_HOME/bin/add-user-keycloak.sh -u admin -p admin -r master
    
    echo ">> Installed application '$appName' (version = $version) in $INSTALL_DIR/${name}"
}

keycloak_connect()
{
    local home_dir=${KEYCLOAK_HOME:-"$INSTALL_DIR/keycloak"}
    local server_url='http://localhost:8180/auth'
    local server_user=${KEYCLOAK_ADMIN_USER:-admin}
    local server_password=${KEYCLOAK_ADMIN_PASSWORD:-admin}
    local mrealm=${1:-master}
    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    if [ -f $home_dir/bin/kcadm.sh ]; then
        echo "$home_dir/bin/kcadm.sh config credentials --realm $mrealm --server $server_url --user $server_user --password $server_password"
        $home_dir/bin/kcadm.sh config credentials --realm $mrealm --server $server_url --user $server_user --password $server_password
    else
        echo "ERROR: not found kcadm.sh in $home_dir/bin/"
        exit 1
    fi
}

keycloak_add_realm()
{
    keycloak_connect $@ 

    local home_dir=${KEYCLOAK_HOME:-"$INSTALL_DIR/keycloak"}
    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi


    kcadm=$home_dir/bin/kcadm.sh
    if [ ! -f $home_dir/bin/kcadm.sh ]; then
        echo "ERROR: not found kcadm.sh in $home_dir/bin/"
        exit 1
    fi

	_REALM_NAME=${realm:-"$name"}
	_REALM_ADMIN_USER=${user:-"$_REALM_NAME"}
	_REALM_ADMIN_PASSWORD=${password:-${_REALM_NAME}123}
	_REALM_CLIENT=${client:-"$_REALM_NAME-auth"}
	_REALM_CLIENT_AUDIENCE=${audience:-'audience'}
	_REALM_CLIENT_SECRET=${secret:-'597eefcc-d46e-4d30-8a37-7f6d2e85c233'}
	# _REALM_ROLES=${REALM_ROLES}

    local args=''
    if [ -n "$loginTheme" ]; then args+=" -s loginTheme=$loginTheme"; fi

	# Now let's create a Realm named "wildfly-realm":
	$kcadm create realms -s realm=$_REALM_NAME -s enabled=true $args

	# add a role for our user, that will match with the Role in the APP
	# for role in $_REALM_ROLES ; do $kcadm create roles -r $_REALM_NAME -s name=$role; done

	$kcadm create roles -r $_REALM_NAME -s name=maintainer;
	$kcadm add-roles -r $_REALM_NAME  \
		--rname maintainer \
		--cclientid realm-management \
		--rolename manage-authorization \
		--rolename manage-users \
		--rolename view-users

	# Realm's client
	CID=$($kcadm create clients \
		-r $_REALM_NAME \
		-s clientId=$_REALM_CLIENT \
		-s publicClient="true" \
		-s enabled=true \
		-s clientAuthenticatorType=client-secret \
		-s secret=$_REALM_CLIENT_SECRET \
		-s 'redirectUris=["*"]'  \
		-s 'directAccessGrantsEnabled=true'  \
		-i
	)

	# audience
	$kcadm create clients/$CID/protocol-mappers/models -r $_REALM_NAME \
		-s name=$_REALM_CLIENT_AUDIENCE \
		-s protocol=openid-connect \
		-s protocolMapper=oidc-audience-mapper \
		-s 'config."included.client.audience"="'$_REALM_CLIENT'"' \
		-s 'config."id.token.claim"="true"' \
		-s 'config."access.token.claim"="true"'

	## Then we add an admin user for this realm:
	$kcadm create users -r $_REALM_NAME \
		-s username="$_REALM_ADMIN_USER" \
		-s email="${email:-"$_REALM_ADMIN_USER@$_REALM_NAME.org"}" \
		-s enabled=true
	$kcadm set-password -r $_REALM_NAME --username $_REALM_ADMIN_USER --new-password "$_REALM_ADMIN_PASSWORD"
	$kcadm add-roles -r $_REALM_NAME --uusername $_REALM_ADMIN_USER --rolename maintainer

    echo "===>> Realm's clientID: $CID"
}
