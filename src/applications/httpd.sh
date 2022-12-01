#!/bin/bash


httpd_install() {
    
    case `plateform` in 
        redhat)
            install httpd mod_ssl mod_fcgid
            sudo mkdir -p /etc/httpd/sites-enabled
            sudo mkdir -p /etc/httpd/sites-availables
            sudo chown apache:apache -R /etc/httpd/sites-enabled /etc/httpd/sites-availables
            # pip install mod_wsgi
            sudo chown apache:apache -R /etc/httpd
            sudo chmod -R g+w /etc/httpd
            if [ -f /etc/httpd/conf.modules.d/00-mpm.conf ]; then
                sudo sed -i -e "s/^LoadModule mpm_event_module/#LoadModule mpm_event_module/" /etc/httpd/conf.modules.d/00-mpm.conf
                sudo sed -i -e "s/^#LoadModule mpm_prefork_module/LoadModule mpm_prefork_module/" /etc/httpd/conf.modules.d/00-mpm.conf
            fi

            sudo mkdir -p /var/log/httpd /run/httpd /run/mod_fcgid /var/log/httpd
            sudo chown apache:apache -R /var/log/httpd /etc/pki/tls /run/httpd /run/mod_fcgid /var/log/httpd /etc/pki/tls
            ;;
        debian|ubuntu)
            exit 0
            # ## https://ubiq.co/tech-blog/install-mod_wsgi-ubuntu/
            # install apache2 apache2-utils libexpat1 ssl-cert libapache2-mod-wsgi # libapache2-mod-php
            # a2enmod ssl
            # # a2enconf mod-wsgi
            # if ! getent passwd apache > /dev/null 2>&1; then
            #     sudo groupadd --system apache
            #     sudo useradd -d /var/apache2 -r -s /bin/false -g apache apache
            # fi
            # sudo chown apache:apache -R /etc/apache2
            # sudo chmod -R g+w /etc/apache2
        ;;
    esac

    sudo mkdir -p /var/www/cgi-bin/
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

