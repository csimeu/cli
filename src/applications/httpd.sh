#!/bin/bash


httpd_install() {
    
    sudo yum install -y httpd mod_ssl mod_wsgi mod_fcgid

    sudo mkdir -p /etc/httpd/sites-enabled
    sudo mkdir -p /etc/httpd/sites-availables
    sudo chown apache:apache -R /etc/httpd/sites-enabled /etc/httpd/sites-availables
    

sudo cat > /etc/httpd/sites-availables/php-fcgi.conf << EOF
# Configure multiple php version
ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
AddHandler php-fcgi .php
#Action php55-fcgi /cgi-bin/php55.fcgi
#Action php56-fcgi /cgi-bin/php56.fcgi
#Action php71-fcgi /cgi-bin/php71.fcgi
#Action php72-fcgi /cgi-bin/php72.fcgi
#Action php73-fcgi /cgi-bin/php73.fcgi
#Action php74-fcgi /cgi-bin/php74.fcgi
EOF

if [[ "$(rpm -E %{rhel})" == "6"  ]];
then
    sudo chkconfig httpd on
else 
    sudo systemctl enable httpd --now
fi

}


## detect if a script is being sourced or not
# if [[ $_ == $0 ]] 
# then
# 	httpd_install "$@"
# fi

