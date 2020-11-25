# #!/bin/bash

# _VERSION=${1:-"8.0.1"}
# _INSTALL_DIR=${2:-"/usr/share"}
# _KEYCLOAK_HOME=${_INSTALL_DIR}/keycloak
# # _PORT=${3:-"8088"}

# ## Install keycloak
# # https://blog.ineat-conseil.fr/2017/11/securisez-vos-apis-spring-avec-keycloak-1-installation-de-keycloak/
# # https://medium.com/@hasnat.saeed/setup-keycloak-server-on-ubuntu-18-04-ed8c7c79a2d9
# mkdir -p $_KEYCLOAK_HOME;
# curl -fSL https://downloads.jboss.org/keycloak/${_VERSION}/keycloak-${_VERSION}.tar.gz -o keycloak-${_VERSION}.tar.gz;
# tar -xzf keycloak-${_VERSION}.tar.gz -C $_KEYCLOAK_HOME --strip-components=1;


# useradd -s /bin/false -r -d $_KEYCLOAK_HOME keycloak;
# chown -R keycloak:keycloak $_KEYCLOAK_HOME;
# chmod g+wr $_KEYCLOAK_HOME
# chmod o+x $_KEYCLOAK_HOME/bin/

# if [[ -n "$USER_ADMIN" ]]; then sudo usermod -aG keycloak $USER_ADMIN; fi

# mkdir -p $_KEYCLOAK_HOME/modules/org/postgresql/main
# curl -fSL https://jdbc.postgresql.org/download/postgresql-42.2.5.jar -o $_KEYCLOAK_HOME/modules/org/postgresql/main/postgresql-42.2.5.jar
# echo '<?xml version="1.0" ?>
# <module xmlns="urn:jboss:module:1.3" name="org.postgresql">
#     <resources>
#         <resource-root path="postgresql-42.2.5.jar"/>
#     </resources>
#     <dependencies>
#         <module name="javax.api"/>
#         <module name="javax.transaction.api"/>
#     </dependencies>
# </module>' > $_KEYCLOAK_HOME/modules/org/postgresql/main/module.xml

# # curl -fSL https://jdbc.postgresql.org/download/postgresql-42.2.5.jar -o $_KEYCLOAK_HOME/postgresql-42.2.5.jar
# # $_KEYCLOAK_HOME/bin/jboss-cli.sh -c "module add --name=org.postgresql  --dependencies=javax.api,javax.transaction.api --resources=postgresql-42.2.5.jar"


# curl -fSL https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.47.tar.gz -o /tmp/mysql-connector-java-5.1.47.tar.gz
# tar -xzf /tmp/mysql-connector-java-5.1.47.tar.gz mysql-connector-java-5.1.47/mysql-connector-java-5.1.47.jar --strip-components=1
# cp -f mysql-connector-java-5.1.47.jar $_KEYCLOAK_HOME
# # $_KEYCLOAK_HOME/bin/jboss-cli.sh -c "module add --name=org.mysql  --dependencies=javax.api,javax.transaction.api --resources=mysql-connector-java-5.1.47.jar"


# mkdir -p /etc/keycloak;
# cp -f $_KEYCLOAK_HOME/docs/contrib/scripts/systemd/wildfly.conf /etc/keycloak/keycloak.conf;
# cp -f $_KEYCLOAK_HOME/docs/contrib/scripts/systemd/launch.sh $_KEYCLOAK_HOME/bin/
# sed -i -e "s|/opt/wildfly|$_KEYCLOAK_HOME|" $_KEYCLOAK_HOME/bin/launch.sh;
# sed -i -e "s|standalone.sh.*|standalone.sh -c \$2 -b \$3 -Djboss.socket.binding.port-offset=100 |" $_KEYCLOAK_HOME/bin/launch.sh;
# chown -R keycloak:keycloak /etc/keycloak

# #  $WILDFLY_MODE $WILDFLY_CONFIG $WILDFLY_BIND
# # /usr/share/keycloak/bin/standalone.sh -c standalone.xml -b 0.0.0.0 -Djboss.socket.binding.port-offset=100

# if [[ ! -f /etc/systemd/system/keycloak.service ]]; then
# echo "
# [Unit]
# Description=The Keycloak Server
# After=syslog.target network.target tomcat.target
# Before=httpd.service

# [Service]
# Environment=LAUNCH_JBOSS_IN_BACKGROUND=1
# EnvironmentFile=/etc/keycloak/keycloak.conf
# User=keycloak
# LimitNOFILE=102642
# PIDFile=$_KEYCLOAK_HOME/keycloak.pid
# ExecStart=$_KEYCLOAK_HOME/bin/launch.sh \$WILDFLY_MODE \$WILDFLY_CONFIG \$WILDFLY_BIND
# StandardOutput=null

# [Install]
# WantedBy=multi-user.target
# " > /etc/systemd/system/keycloak.service
# fi

# $_KEYCLOAK_HOME/bin/add-user-keycloak.sh -u admin -p admin -r master
