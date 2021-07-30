#!/bin/bash

# Install tomcat
FORCE=0
IS_DEFAULT=0
INSTALL_DIR=/usr/share

# Reads arguments options
function parse_tomcat_arguments()
{
    # if [ $# -ne 0 ]; then
    local TEMP=`getopt -o p::,f --long version::,tomcat-config::,users-config::,config-file::,install-dir,force,default -n "$0" -- "$@"`
      
    eval set -- "$TEMP"
    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            -h|--help) _HELP=1 ; shift 1 ;;
            -f|--force) FORCE=1 ; shift 1 ;;
            --default) IS_DEFAULT=1 ; shift 1 ;;
            --install-dir) INSTALL_DIR=${2%"/"} ; shift 2 ;;
            --data) data=${2%"/"} ; shift 2 ;;   
            --file-config) config_file=${2:-"$config_file"}; shift 2 ;;
            --version) version=${2:-"$version"}; shift 2 ;;
            # --tomcat-config) tomcat_config=${2:-"$tomcat_config"}; shift 2 ;;
            --users-config) users_config=${2:-"$users_config"}; shift 2 ;;
            --) shift ; break ;;
            *) echo "Internal error! $1" ; exit 1 ;;
        esac
    done

    shift $(expr $OPTIND - 1 )
    _parameters=$@
    
  # fi
}

function tomcat_install() 
{
	set -e
	local users_config=
	local file_config=
	# local INSTALL_DIR=/usr/share
	local version=$TOMCAT_DEFAULT_VERSION
    # echo $@
    local _parameters=
    parse_tomcat_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi
    # data=${data:-"$1"}
    # data=${data:-"."}
    # data=${data%"/"} 

	if [[ -n "$file_config" && ! -f $file_config ]]
	then
    echo "File not found $file_config" 
    exit 1
	fi

	if [[ -n "$users_config" && ! -f $users_config ]]
	then
    echo "File not found $users_config" 
    exit 1
	fi

    # https://computingforgeeks.com/install-apache-tomcat-9-on-linux-rhel-centos/
    if ! getent passwd tomcat > /dev/null 2>&1; then
        sudo groupadd --system tomcat
        sudo useradd -d /usr/share/tomcat -r -s /bin/false -g tomcat tomcat
    fi
    
    
    case "$version" in
        "7") version=7.0.90;;
        "8") version=8.5.69;;
        "9") version=9.0.50;;
        *)
        ;;
    esac

    if [ "1" == "$FORCE" ]
    then 
        sudo rm -rf $INSTALL_DIR/tomcat-$version
    fi

    if [ -d $INSTALL_DIR/tomcat-$version ]
    then 
        echo "Tomcat $version already installed"
        exit 0
    fi

    cd /tmp/releases
    local major=`echo $version | cut -d. -f1`
    if [ ! -f apache-tomcat-${version}.tar.gz ]
    then
        wget https://archive.apache.org/dist/tomcat/tomcat-$major/v${version}/bin/apache-tomcat-${version}.tar.gz
    fi

    sudo tar xf apache-tomcat-${version}.tar.gz -C $INSTALL_DIR
    sudo mv $INSTALL_DIR/apache-tomcat-$version $INSTALL_DIR/tomcat-$version
    sudo chown -R tomcat:tomcat $INSTALL_DIR/tomcat-$version

    if [ "1" == "$IS_DEFAULT" ]
    then
        if [ -L /etc/tomcat ]; then unlink /etc/tomcat; fi
        sudo rm -rf /usr/share/tomcat etc/tomcat
        sudo ln -s $INSTALL_DIR/tomcat-$version /usr/share/tomcat
        sudo ln -s /usr/share/tomcat/conf /etc/tomcat
        sudo chown -R tomcat:tomcat /usr/share/tomcat /etc/tomcat

        if [[ "6" != $OS_VERSION ]]; then

            sudo cat > /etc/systemd/system/tomcat.service << EOF
[Unit]
Description=Tomcat $version Server
After=syslog.target network.target

[Service]
Type=forking
User=tomcat
Group=tomcat

Environment=JAVA_HOME=$(readlink -f $(which java) | sed -e "s/\/bin\/java//")
Environment='JAVA_OPTS=-Djava.awt.headless=true'
Environment=CATALINA_HOME=/usr/share/tomcat
Environment=CATALINA_BASE=/usr/share/tomcat
Environment=CATALINA_PID=/usr/share/tomcat/temp/tomcat.pid
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'

ExecStart=/usr/share/tomcat/bin/startup.sh
ExecStop=/usr/share/tomcat/bin/shutdown.sh 

[Install]
WantedBy=multi-user.target
EOF
            # sudo systemctl daemon-reload
        fi
    fi

    # echo "CATALINA_HOME=/usr/share/tomcat" >> /etc/profile.d/environnments.sh
}


# function tomcat_make_install() 
# {
#     #https://nvbach.blogspot.com/2019/04/installing-blazegraph-on-linux-debian.html
#     groupadd tomcat
#     mkdir /opt/tomcat
#     useradd -g tomcat -d /opt/tomcat -s /bin/nologin tomcat

#     cd /tmp/releases
#     wget [link to the Tomcat  7.0.90tar.gz file]
#     tar -zxvf apache-tomcat-7.0.90.tar.gz
#     mv apache-tomcat-7.0.90/* /opt/tomcat
#     chown -R tomcat:tomcat /opt/tomcat/
    
#     echo "CATALINA_HOME=/opt/tomcat" >> /etc/profile.d/environnments.sh
# }

# if [ ! $# -eq 0 ]; 
# then
#   install_tomcat $@
# fi
