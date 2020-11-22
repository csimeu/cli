#!/bin/bash
#
# Scripts cpm: Cen-R Package Manager
#
#   Emploi:     
#
##########   INSTANCE DE PRODUCTION  ##########
#


# Stop on first error [duplicate]
set -e

# source env_vars.sh
# source cpm_funtions.sh
# source git.sh
# source cenr.sh
# source files.sh
# source dal.sh


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
    *)
        cmd="${cmd//:/_}" 
        shift
        $cmd $@
    ;;
esac
