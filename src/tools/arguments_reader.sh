

# Reads arguments options
function read_arguments()
{
    local TEMP=`getopt -o p::,f::,h,v,${SHORT:-'s'} --long ${lONG:-'long'},help,debug,verbose,force,default,name::,version::,filename::,file::,path::,password::,user::,email::,host::,port:: -n "$0" -- "$@"`

	eval set -- "$TEMP"
    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            -h|--help) HELP=1 ; shift 1 ;;
            --debug) DEBUG=1 ; shift 1 ;;
            --verbose) VERBOSE=1 ; shift 1 ;;
            --force) FORCE=1 ; shift 1 ;;
            --default) IS_DEFAULT=1 ; shift 1 ;;
            --superuser) IS_SUPERUSER=1 ; shift 1 ;;
            --name) name=${2}; names+="${2} ";shift 2 ;;
            --user) user=${2}; users+="${2} "; shift 2 ;;
            -f|--filename) filename=${2}; shift 2 ;;
            --file) file=${2}; shift 2 ;;
            -p|--path) path=${2%"/"} ; shift 2 ;;
            --data) data=${2%"/"} ; shift 2 ;;
            --version) version=${2}; shift 2 ;;
            --install-dir) install_dir=${2%"/"}; shift 2 ;;
            --home-dir) home_dir=${2%"/"} ; shift 2 ;;
            --file-config) config_file=${2}; shift 2 ;;
            --catalina-home) catalina_home=${2}; shift 2 ;;
            # --users-config) users_config=${2:-"$users_config"}; shift 2 ;;
            --offset) offset=${2:-"$port_offset"}; shift 2 ;;
            --port) port=${2}; shift 2 ;;
            --host) host=${2}; shift 2 ;;
            --password) password=${2}; shift 2 ;;
            --db-name) db_name=${2}; shift 2 ;;
            --db-user) db_user=${2}; shift 2 ;;
            --db-password) dp_password=${2}; shift 2 ;;
            --db-host) db_host=${2}; shift 2 ;;
            --db-port) db_port=${2}; shift 2 ;;
            --realm) realm=${2}; shift 2 ;;
            --email) email=${2}; shift 2 ;;
            --url) url=${2//\//\/\//}; shift 2 ;;
            --client) client=${2}; shift 2 ;;
            --audience) audience=${2}; shift 2 ;;
            --secret) secret=${2}; shift 2 ;;
            --theme) theme=${2}; shift 2 ;;
            --) shift ; break ;;
            *) echo "Internal error! $1" ; exit 1 ;;
        esac
    done

    shift $(expr $OPTIND - 1 )
    _parameters=$@
    
  # fi
}
