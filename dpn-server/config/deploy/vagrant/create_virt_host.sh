#!/bin/bash

rm -f /etc/apache2/sites-available/dpn.conf

cat <<EOF > /etc/apache2/sites-available/dpn.conf
<VirtualHost *:80>
        ServerAdmin bhock@umich.edu
        DocumentRoot /l/local/dpn/current/public
        SetEnv DPN_NAMESPACE $1
        SetEnv DPN_SALT $2
        RailsEnv development
        ErrorLog ${APACHE_LOG_DIR}/dpn.error.log
        CustomLog ${APACHE_LOG_DIR}/dpn.access.log combined
        LogLevel info
        <Directory /l/local/dpn/current/public>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride None
                Order allow,deny
                allow from all
        </Directory>
</VirtualHost>
EOF
