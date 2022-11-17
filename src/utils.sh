
#!/bin/bash

# check to see if this file is being run or sourced from another script
is_sourced () {
    [[ "${FUNCNAME[1]}" == "source" ]]  && return 0
    return 1
}

# Checks if program was installed
has_command() {
    if [ -x "$(command -v ${1:-null})" ]; then true; else false; fi
}

# Checks if given string is an valid url
function is_url()
{
    # -- supported protocols (HTTP, HTTPS, FTP, FTPS, SCP, SFTP, TFTP, DICT, TELNET, LDAP or FILE) --
    regex='([a-z]{3,6})://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
    string=$1
    if [[ $string =~ $regex ]]
    then 
        true
    else
        false
    fi
}

# Transform snake words to camel
function snake_to_camel()
{
    echo $(echo $1 | sed -r 's/(^|_)(\w)/\U\2/g' )
}

# Transform camel words to snake
function camel_to_snake() 
{
    echo $(echo $1 | sed 's/\(.\)\([A-Z]\)/\1_\2/g' | tr '[:upper:]' '[:lower:]')
}

function is_alphanum() 
{    
    regex="^[a-zA-Z0-9_]+$"

    if [[ $1 =~ $regex ]]
    then 
        true
    else
        false
    fi
}


# get plateform
function plateform() 
{
    local value=`plateform_name`
    case $value in
        centos|rhel|fedora)
            value="redhat";
        ;;
        # *)
        #     value="debian"
        # ;;
    esac

    echo $value
}

# get plateform name
function plateform_name() 
{
    local value=$(awk -F= '/^ID=/{print $2}' /etc/os-release)
    echo ${value//\"/}
}

# get plateform version
function plateform_version() 
{
    local value=$(awk -F= '/^VERSION_ID=/{print $2}' /etc/os-release)
    echo ${value//\"/}
}


# get plateform version
function os_type() 
{
    local value=$(awk -F= '/^ID_LIKE=/{print $2}' /etc/os-release)
    value=${value//\"/}
    regex="^(debian|ubuntu)$"
    if [[ $value =~ $regex ]]
    then 
        true
    else
        false
    fi
}
function is_alpine() 
{
    local value=$(plateform_name)
    regex="^(alpine)$"
    if [[ $value =~ $regex ]]
    then 
        true
    else
        false
    fi
}
function is_debian() 
{
    local value=$(awk -F= '/^ID_LIKE=/{print $2}' /etc/os-release)
    value=${value//\"/}
    regex="^(debian|ubuntu)$"
    if [[ $value =~ $regex ]]
    then 
        true
    else
        false
    fi
}

function is_redhat()
{    
    local value=$(awk -F= '/^ID_LIKE=/{print $2}' /etc/os-release)
    value=${value//\"/}
    regex="^(rhel|centos|fedora)$"

    # echo $value
    if [[ $value =~ $regex ]]
    then 
        true
    else
        false
    fi
}

function install() 
{
    # echo "sudo yum install $@"
    case `plateform` in 
        debian|ubuntu)
            execute apt-get install -y $@
            execute rm -f /var/cache/apt/* 
        ;;
            
        redhat)
            execute yum install -y $@
            execute rm -f /var/cache/yum/* 
            execute rm -f /var/cache/dnf/* 
        ;;
            
        alpine)
            execute apk add $@
            execute rm -f /var/cache/apk/* 
        ;;
    esac
}

function remove() 
{
    # echo "sudo yum remove $@"
    case `plateform` in 
        debian|ubuntu)
            execute apt-get remove $@
        ;;
            
        redhat)
            execute yum remove $@
        ;;
            
        alpine)
            execute apk remove $@
        ;;
    esac
}


function execute() 
{
    if [ "$EUID" -ne 0 ]; then sudo $@; else $@; fi
}

function command_resolver() 
{ 
    cmd=$1
    
    case $cmd in 
        useradd) echo "${password}" | passwd $username --stdin ;;
        usermod) if [ "$(plateform)" == "alpine" ]; then echo 'moduser'; fi;;
        *) echo $cmd ;;
    esac
    # name="INFRA_ADMIN_GROUP_UID LOGNAME INFRA_ADMIN_PASSWORD"
}

function servicectl() 
{
    local cmd=$1
    local svc=$2

    #https://www.cyberciti.biz/faq/centos-stop-start-restart-sshd-command/

    # echo "sudo yum install $@"
    case $cmd in 
        enable)
            case `plateform` in 
                alpine) rc-update add $svc;;
                redhat) if [ "$(plateform_version)" == "6" ]; then execute chkconfig $svc on; else execute systemctl enable $svc; fi ;;
            esac
            ;;
        disable)
            case `plateform` in 
                alpine) rc-update remove $svc;;
                redhat) if [ "$(plateform_version)" == "6" ]; then execute chkconfig $svc off; else execute systemctl disable $svc; fi ;;
            esac
            ;;
        *)
            case `plateform` in 
                redhat) if [ "$(plateform_version)" == "6" ]; then execute /etc/init.d/$svc $cmd; else  execute service $svc $cmd; fi ;;
                *) execute service $svc $cmd ;;
            esac
            ;;
    esac

}

