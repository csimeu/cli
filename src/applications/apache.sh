#!/bin/bash


apache_install() {
    
    case `plateform` in 
        alpine)
            # https://github.com/nimmis/docker-alpine-apache/blob/master/Dockerfile
            install apache2 apache2-ssl apache2-mod-wsgi apache2-proxy libxml2-dev apache2-utils
            sudo sed -i '/LoadModule rewrite_module/s/^#//g' /etc/apache2/httpd.conf
            sudo sed -i -e "s|^# Mutex .*$|Mutex file:/var/lock/apache2 default|" /etc/apache2/httpd.conf
            if ! getent passwd apache > /dev/null 2>&1; then
                sudo groupadd --system apache
                sudo useradd -d /var/www -r -s /bin/false -g apache apache
            fi
            sudo mkdir -p /var/lock/apache2
            sudo chown apache:apache -R /etc/apache2 /var/run/apache2 /var/lock/apache2 /etc/ssl/apache2
            sudo chmod -R g+w /etc/apache2 /var/run/apache2 /var/lock/apache2 
            ;;
        redhat)
            install httpd mod_ssl mod_fcgid
            sudo mkdir -p /etc/httpd/sites-enabled
            sudo mkdir -p /etc/httpd/sites-availables
            sudo chown apache:apache -R /etc/httpd/sites-enabled /etc/httpd/sites-availables
            # pip install mod_wsgi
            sudo chown apache:apache -R /etc/httpd
            sudo chmod -R g+w /etc/httpd
            ;;
        debian)
            ## https://ubiq.co/tech-blog/install-mod_wsgi-ubuntu/
            install apache2 apache2-utils libexpat1 ssl-cert libapache2-mod-wsgi*
            # install libapache2-mod-wsgi 
            # execute a2enconf mod-wsgi
            execute a2enmod ssl
            execute a2enmod proxy
            execute a2enmod proxy_http
            execute a2enmod proxy_balancer
            execute a2enmod lbmethod_byrequests
            execute a2enmod rewrite
            if ! getent passwd apache > /dev/null 2>&1; then
                execute groupadd --system apache
                execute useradd -d /var/www -r -s /bin/false -g apache apache
            fi
            if [ -f /etc/apache2/envvars ]; then sed -i -e "s/www-data/apache/g" /etc/apache2/envvars ; fi
            
            sudo sed -i -e "s|^#Mutex |Mutex |g" /etc/apache2/apache2.conf
            execute chown apache:apache -R /etc/apache2
            execute chmod -R g+w /etc/apache2

            if [[ ! -f /etc/profile.d/apache2.sh && ! -L /etc/profile.d/apache2.sh ]]; then
                sudo ln -s /etc/apache2/envvars /etc/profile.d/apache2.sh ; 
            fi

            source /etc/apache2/envvars
            sudo chown apache:apache -R ${APACHE_LOG_DIR} ${APACHE_RUN_DIR} ${APACHE_LOCK_DIR}
            sudo sed -i -e "s|\${APACHE_PID_FILE}|/var/run/apache2/apache.pid|g" /etc/apache2/apache2.conf
            sudo sed -i -e "s|\${APACHE_RUN_USER}|apache|g" /etc/apache2/apache2.conf
            sudo sed -i -e "s|\${APACHE_RUN_GROUP}|apache|g" /etc/apache2/apache2.conf
            sudo sed -i -e "s|^#Mutex |Mutex |g" /etc/apache2/apache2.conf
            find /etc/apache2/ -type f -exec sudo sed -i -e "s|\${APACHE_LOG_DIR}|${APACHE_LOG_DIR}|g" {} \;
            find /etc/apache2/ -type f -exec sudo sed -i -e "s|\${APACHE_RUN_DIR}|${APACHE_RUN_DIR}|g" {} \;
            find /etc/apache2/ -type f -exec sudo sed -i -e "s|\${APACHE_LOCK_DIR}|${APACHE_LOCK_DIR}|g" {} \;
        ;;
    esac

    if [ -d /var/log/apache2 ]; then
        sudo chown apache:apache -R /var/log/apache2
    fi
    if [ -d /var/lock/apache2 ]; then
        sudo chown apache:apache -R /var/lock/apache2
    fi

    sudo mkdir -p /var/www/cgi-bin/
    # sudo chown apache:apache -R /var/www/cgi-bin/
    sudo chown apache:apache -R /var/www
    sudo chmod -R g+w /var/www

    if [[ -n "$ADMIN_USER" && $(getent passwd $ADMIN_USER)  ]];
    then    
        sudo usermod -aG apache $ADMIN_USER;
    fi
    

# sudo cat > /etc/httpd/sites-availables/php-fcgi.conf << EOF
# # Configure multiple php version
# ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
# AddHandler php-fcgi .php
# #Action php55-fcgi /cgi-bin/php55.fcgi
# #Action php56-fcgi /cgi-bin/php56.fcgi
# #Action php71-fcgi /cgi-bin/php71.fcgi
# #Action php72-fcgi /cgi-bin/php72.fcgi
# #Action php73-fcgi /cgi-bin/php73.fcgi
# #Action php74-fcgi /cgi-bin/php74.fcgi
# EOF

# if [[ "$(rpm -E %{rhel})" == "6"  ]];
# then
#     sudo chkconfig httpd on
# else 
#     sudo systemctl enable httpd
# fi

}

