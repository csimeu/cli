#!/bin/bash

# Install fedora commons repository


# Reads arguments options
function parse_fcrepo_arguments()
{
  # if [ $# -ne 0 ]; then
    local TEMP=`getopt -o p:: --long data::,name::,version::,users-config::,config-file:: -n "$0" -- "$@"`
    
	eval set -- "$TEMP"
    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            --data) data=${2%"/"} ; shift 2 ;;
            --name) name=${2} ; shift 2 ;;
            --file-config) config_file=${2:-"$config_file"}; shift 2 ;;
            --version) version=${2:-"$version"}; shift 2 ;;
            # --tomcat-config) tomcat_config=${2:-"$tomcat_config"}; shift 2 ;;
            --users-config) users_config=${2:-"$users_config"}; shift 2 ;;
            # --db-name) DB_NAME=${2:-"$DB_NAME"}; shift 2 ;;
            # --db-user) DB_USER=${2:-"$DB_USER"}; shift 2 ;;
            # --db-password) DB_PASSWORD=${2:-"$DB_PASSWORD"}; shift 2 ;;
            # --db-host) DB_HOST=${2:-"$DB_HOST"}; shift 2 ;;
            # --db-port) DB_PORT=${2:-"$DB_PORT"}; shift 2 ;;
            --) shift ; break ;;
            *) echo "Internal error! $1" ; exit 1 ;;
        esac
    done

    shift $(expr $OPTIND - 1 )
    _parameters=$@
    
  # fi
}

function fcrepo_install() 
{
    set -e
    local version=4.7.5
    local data=
    local name=
    local catalina_home=/usr/share/tomcat
    # local DB_PASSWORD=
    # local DB_HOST=localhost
    # local DB_PORT=3306
    local fcrepo_config=
    local file_config=
    # echo $@
    local _parameters=
    parse_fcrepo_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi
    # data=${data:-"$1"}
    data=${data:-"/var/lib/fcrepo"}
    data=${data%"/"} 

    if ! getent passwd tomcat > /dev/null 2>&1; then
        install-tomcat.sh .
    fi

    # ENV PATH $CATALINA_HOME/bin:$PATH

    # https://github.com/fcrepo4/fcrepo4/releases/download/fcrepo-5.1.0/fcrepo-webapp-5.1.0.war
    # https://github.com/fcrepo4/fcrepo4/releases/download/fcrepo-4.7.5/fcrepo-webapp-4.7.5.war

    case "$version" in

        "4") version=4.7.5;;

        "5") version=5.1.0;;
        *)
        ;;
    esac
    
    # ARG FCREPO_VERSION=4.7.5
    # ARG FCREPO_TAG=4.7.5
    # ARG FcrepoConfig=
    curl -fSL https://github.com/fcrepo4-exts/fcrepo-webapp-plus/releases/download/fcrepo-webapp-plus-$version/fcrepo-webapp-plus-$fcrepo_config$version.war -o fcrepo-$fcrepo_config$version.war
    #
    local ModeshapeConfig=file-simple
    local JDBCConfig=
  # ARG FCREPO_DIR=${APP_DIR}/fcrepo
    sudo mkdir -p "${data}" && sudo chown tomcat:tomcat -R ${data} \
    && sudo echo 'JAVA_OPTS="-Dfcrepo.modeshape.configuration=classpath:/config/'$ModeshapeConfig'/repository.json '$JDBCConfig' -Dfcrepo.home='${data}' -Dfcrepo.audit.container=/audit"' >> /etc/tomcat/tomcat.conf \
    && sudo mv fcrepo-$fcrepo_config$version.war "${catalina_home}"/webapps/${name:-"fcrepo-$version"}.war

}

## detect if a script is being sourced or not
if [[ $_ == $0 ]] 
then
  fcrepo_install $@
fi

