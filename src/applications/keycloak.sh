#!/bin/bash

function keycloak_install() 
{
    set -e

    local version=8.0.1
    local name=keycloak
    local install_dir=/usr/share
    local port_offset=100

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    local KEYCLOAK_HOME=${install_dir}/$name

    # _PORT=${3:-"8088"}

    ## Install keycloak
    # https://blog.ineat-conseil.fr/2017/11/securisez-vos-apis-spring-avec-keycloak-1-installation-de-keycloak/
    # https://medium.com/@hasnat.saeed/setup-keycloak-server-on-ubuntu-18-04-ed8c7c79a2d9
    mkdir -p $KEYCLOAK_HOME;
    curl -fSL https://downloads.jboss.org/keycloak/${version}/keycloak-${version}.tar.gz -o keycloak-${version}.tar.gz;
    tar -xzf keycloak-${version}.tar.gz -C $KEYCLOAK_HOME --strip-components=1;

    useradd -s /bin/false -r -d $KEYCLOAK_HOME keycloak;
    chown -R keycloak:keycloak $KEYCLOAK_HOME;
    chmod g+wr $KEYCLOAK_HOME
    chmod o+x $KEYCLOAK_HOME/bin/

    if [[ -n "$USER_ADMIN" ]]; then sudo usermod -aG keycloak $USER_ADMIN; fi

    mkdir -p $KEYCLOAK_HOME/modules/org/postgresql/main
    curl -fSL https://jdbc.postgresql.org/download/postgresql-42.2.5.jar -o $KEYCLOAK_HOME/modules/org/postgresql/main/postgresql-42.2.5.jar
echo '<?xml version="1.0" ?>
<module xmlns="urn:jboss:module:1.3" name="org.postgresql">
    <resources>
        <resource-root path="postgresql-42.2.5.jar"/>
    </resources>
    <dependencies>
        <module name="javax.api"/>
        <module name="javax.transaction.api"/>
    </dependencies>
</module>' > $KEYCLOAK_HOME/modules/org/postgresql/main/module.xml

    # curl -fSL https://jdbc.postgresql.org/download/postgresql-42.2.5.jar -o $KEYCLOAK_HOME/postgresql-42.2.5.jar
    # $KEYCLOAK_HOME/bin/jboss-cli.sh -c "module add --name=org.postgresql  --dependencies=javax.api,javax.transaction.api --resources=postgresql-42.2.5.jar"


    curl -fSL https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.47.tar.gz -o /tmp/mysql-connector-java-5.1.47.tar.gz
    tar -xzf /tmp/mysql-connector-java-5.1.47.tar.gz mysql-connector-java-5.1.47/mysql-connector-java-5.1.47.jar --strip-components=1
    cp -f mysql-connector-java-5.1.47.jar $KEYCLOAK_HOME
    # $KEYCLOAK_HOME/bin/jboss-cli.sh -c "module add --name=org.mysql  --dependencies=javax.api,javax.transaction.api --resources=mysql-connector-java-5.1.47.jar"


    mkdir -p /etc/keycloak;
    cp -f $KEYCLOAK_HOME/docs/contrib/scripts/systemd/wildfly.conf /etc/keycloak/keycloak.conf;
    cp -f $KEYCLOAK_HOME/docs/contrib/scripts/systemd/launch.sh $KEYCLOAK_HOME/bin/
    sed -i -e "s|/opt/wildfly|$KEYCLOAK_HOME|" $KEYCLOAK_HOME/bin/launch.sh;
    sed -i -e "s|standalone.sh.*|standalone.sh -c \$2 -b \$3 -Djboss.socket.binding.port-offset=$port_offset |" $KEYCLOAK_HOME/bin/launch.sh;
    chown -R keycloak:keycloak /etc/keycloak

#  $WILDFLY_MODE $WILDFLY_CONFIG $WILDFLY_BIND
# /usr/share/keycloak/bin/standalone.sh -c standalone.xml -b 0.0.0.0 -Djboss.socket.binding.port-offset=100

if [[ ! -f /etc/systemd/system/keycloak.service ]]; then
echo "
[Unit]
Description=The Keycloak Server
After=syslog.target network.target tomcat.target
Before=httpd.service

[Service]
Environment=LAUNCH_JBOSS_IN_BACKGROUND=1
EnvironmentFile=/etc/keycloak/keycloak.conf
User=keycloak
LimitNOFILE=102642
PIDFile=$KEYCLOAK_HOME/keycloak.pid
ExecStart=$KEYCLOAK_HOME/bin/launch.sh \$WILDFLY_MODE \$WILDFLY_CONFIG \$WILDFLY_BIND
StandardOutput=null

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/keycloak.service
fi

    $KEYCLOAK_HOME/bin/add-user-keycloak.sh -u admin -p admin -r master
}
