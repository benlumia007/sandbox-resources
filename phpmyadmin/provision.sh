#!/bin/bash

noroot() {
    sudo -EH -u "vagrant" "$@";
}

if [[ ! -d "/srv/www/dashboard/public_html/phpmyadmin" ]]; then
    mkdir -p "/srv/www/dashboard/public_html/phpmyadmin"
    cd "/srv/www/dashboard/public_html/phpmyadmin"
    wget -q https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.zip -O phpmyadmin.zip
    unzip -q phpmyadmin.zip -d "/srv/www/dashboard/public_html/phpmyadmin"
    mv phpMyAdmin-5.0.2-all-languages/* "/srv/www/dashboard/public_html/phpmyadmin"
    rm -rf phpMyAdmin-5.0.2-all-languages
    rm phpmyadmin.zip
fi
