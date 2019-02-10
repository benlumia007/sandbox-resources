#!/bin/bash

noroot() {
    sudo -EH -u "vagrant" "$@";
}

if [[ ! -d "/srv/www/dashboard/public_html" ]]; then
    echo "creating folder phpmyadmin"
    mkdir -p "/srv/www/dashboard/public_html"
    cd "/srv/www/dashboard/public_html/phpmyadmin"
    echo "extracting phpMyAdmin-4.8.5-all-languages"
    wget https://files.phpmyadmin.net/phpMyAdmin/4.8.5/phpMyAdmin-4.8.5-all-languages.zip -O phpmyadmin.zip
    unzip phpmyadmin.zip -d "/srv/www/dashboard/public_html"
    mv "phpMyAdmin-4.8.5-all-languages" "phpmyadmin"
fi