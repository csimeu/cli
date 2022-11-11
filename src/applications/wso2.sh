#!/bin/bash


wso2_install() {
    _VERSION=${1:-"5.7.0"}
    _INSTALL_DIR=${2:-"/usr/share"}

    curl -fSL https://bintray.com/wso2/rpm/rpm -o /etc/yum.repos.d/bintray-wso2-rpm.repo
    install wso2is-$_VERSION

    _WSO2_DIR=/usr/lib64/wso2/wso2is/$_VERSION
    _WSO2_HOME=/usr/lib64/wso2

    if [[ -n "${_INSTALL_DIR}" && ! -d ${_INSTALL_DIR}/wso2 && ! -L ${_INSTALL_DIR}/wso2  ]]; then
        ln -s $_WSO2_DIR ${_INSTALL_DIR}/wso2
    fi

    if ! getent passwd wso2 > /dev/null 2>&1; then
        useradd -r -d ${_WSO2_HOME}/ wso2
    fi

    chown -R wso2:wso2 ${_WSO2_HOME}
    if [[ -n "$ADMIN_USER" && $(getent passwd $ADMIN_USER)  ]]; then sudo usermod -aG wso2 $ADMIN_USER; fi

if [[ ! -f /etc/systemd/system/wso2.service ]]; then
echo "
[Unit]
Description=WSO2 server identity provider
After=syslog.target network.target

[Service]
Type=forking
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CARBON_HOME=${_WSO2_DIR}
PermissionsStartOnly=true
PIDFile=${_WSO2_DIR}/wso2carbon.pid

ExecStart=${_WSO2_DIR}/bin/wso2server.sh start
ExecStop=${_WSO2_DIR}/bin/wso2server.sh stop

TimeoutStartSec=30s
Restart=on-failure
RestartSec=10s
RemainAfterExit=yes

User=wso2
[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/wso2.service
fi
}
