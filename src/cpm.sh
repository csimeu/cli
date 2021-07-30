#!/bin/bash
#
# Scripts cpm: Csimeu Package Manager
#
#   Emploi:     
#
##########   INSTANCE DE PRODUCTION  ##########
#


# Stop on first error [duplicate]
OS_NAME=$(plateform_name)
OS_VERSION=$(plateform_version)
mkdir -p /tmp/releases

_home() {
    echo ${0/cpm/..}
}

_self_update() {
    cd `_home` && git pull origin master
}

_run_cpm() {
    set -e
    if [ $# -eq 0 ]; then
        # Commande invalide
        echo "Commande invalide!"
        exit 1
    fi

    cmd=$1

    case "$cmd" in
        "cc:dev")
            shift
            symfony_cc --env=dev $@
            exit 0;
            ;;
        "cc" | "symfony:cc")
            shift
            symfony_cc $@
            exit 0;
            ;;
        "self-update")
            shift
            _self_update $@
            exit 0;
            ;;
        *)
            cmd="${cmd//:/_}" 
            shift
            $cmd $@
        ;;
    esac

}

## detect if a script is being sourced or not
if [[ $(basename $0) == 'cpm' ]]
then
	_run_cpm "$@"
fi

