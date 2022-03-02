

# Reads arguments options
function read_application_arguments()
{
    ISDEFAULT=false;
    IS_SUPERUSER=0
    local long="help,force,default,superuser,data::,name::,version::,file::,users-config::,config-file::,catalina-home::,install-dir::,port-offset::,data-dir::,home-dir::"
    long+=",db-name::,db-user::,db-password::,db-host::,db-port::"
    long+=",realm::,url::,client::,audience::,secret::,login-theme::"
    local TEMP=`getopt -o p::,f,h --long $long,password::,user::,email::,host::,port:: -n "$0" -- "$@"`

	eval set -- "$TEMP"
    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            -f|--force) FORCE=1 ; shift 1 ;;
            --default) IS_DEFAULT=1 ; shift 1 ;;
            --data) data=${2%"/"} ; shift 2 ;;
            --home-dir) home_dir=${2%"/"} ; shift 2 ;;
            --name) name=${2} ; shift 2 ;;
            --file) file=${2}; shift 2 ;;
            --file-config) config_file=${2:-"$config_file"}; shift 2 ;;
            --version) version=${2:-"$version"}; shift 2 ;;
            --catalina-home) catalina_home=${2:-"$catalina_home"}; shift 2 ;;
            --users-config) users_config=${2:-"$users_config"}; shift 2 ;;
            --install-dir) INSTALL_DIR=${2:-"$INSTALL_DIR"}; shift 2 ;;
            --port-offset) port_offset=${2:-"$port_offset"}; shift 2 ;;
            --port) port=${2:-"$port"}; shift 2 ;;
            --user) user=${2:-"$user"}; shift 2 ;;
            --host) host=${2:-"$host"}; shift 2 ;;
            --password) password=${2:-"$password"}; shift 2 ;;
            --superuser) IS_SUPERUSER=1 ; shift 1 ;;
            --db-name) DB_NAME=${2:-"$DB_NAME"}; shift 2 ;;
            --db-user) DB_USER=${2:-"$DB_USER"}; shift 2 ;;
            --db-password) DB_PASSWORD=${2:-"$DB_PASSWORD"}; shift 2 ;;
            --db-host) DB_HOST=${2:-"$DB_HOST"}; shift 2 ;;
            --db-port) DB_PORT=${2:-"$DB_PORT"}; shift 2 ;;
            --realm) realm=${2:-"$realm"}; shift 2 ;;
            --email) email=${2:-"$email"}; shift 2 ;;
            --url) url=${2:-"$url"}; shift 2 ;;
            --client) client=${2:-"$client"}; shift 2 ;;
            --audience) audience=${2:-"$audience"}; shift 2 ;;
            --secret) secret=${2:-"$secret"}; shift 2 ;;
            --login-theme) loginTheme=${2:-"$loginTheme"}; shift 2 ;;
            --) shift ; break ;;
            *) echo "Internal error! $1" ; exit 1 ;;
        esac
    done

    shift $(expr $OPTIND - 1 )
    _parameters=$@
    
  # fi
}
