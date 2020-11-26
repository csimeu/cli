

# Reads arguments options
function read_application_arguments()
{
    local TEMP=`getopt -o p:: --long data::,name::,version::,users-config::,config-file::,catalina-home::install-dir:: -n "$0" -- "$@"`
    
	eval set -- "$TEMP"
    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            --data) data=${2%"/"} ; shift 2 ;;
            --name) name=${2} ; shift 2 ;;
            --file-config) config_file=${2:-"$config_file"}; shift 2 ;;
            --version) version=${2:-"$version"}; shift 2 ;;
            --catalina-home) catalina_home=${2:-"$catalina_home"}; shift 2 ;;
            --users-config) users_config=${2:-"$users_config"}; shift 2 ;;
            --install-dir) install_dir=${2:-"$install_dir"}; shift 2 ;;
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
