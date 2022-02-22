#!/bin/bash

# service




function mysql_service() 
{
    set -e
    # local serviceName= $1
    local cmd=$1
    
    case `plateform` in 
        redhat)
			if [[ `plateform_version` =~ 6 ]]; then 
                /etc/init.d/mysqld $cmd; 
            else 
                systemctl $cmd mysqld; 
            fi
            ;;
        debian)
			systemctl $cmd mysql;
        ;;
    esac
}


# if [ ! $# -eq 0 ]; 
# then
#   install_solr $@
# fi
