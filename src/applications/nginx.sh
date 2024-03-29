#!/bin/bash


nginx_install() {
    install -y nginx
    
    if [[ -n "$ADMIN_USER" && $(getent passwd $ADMIN_USER)  ]]; then sudo usermod -aG nginx $ADMIN_USER; fi
}

