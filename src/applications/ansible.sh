#!/bin/bash

install_ansible() {
    case `platform` in 

        debian|ubuntu)
            sudo apt update
            sudo apt install ansible -y
        ;;

        redhat)
            sudo dnf update -y
            sudo dnf install epel-release -y
            sudo dnf install ansible -y
        ;;

        # alpine)
        # ;;
        *)
            echo "No script implemented for this platform: $(platform)";
            exit 100;
        ;;
    esac

    ansible --version
}
