#!/bin/bash

noroot() {
    sudo -EH -u "vagrant" "$@";
}

if [[ ! -d "/srv/www/dashboard/phpmyadmin" ]]; then
    echo "creating folder phpmyadmin"
    mkdir -p "/srv/www/dashboard/phpmydmin"
    cd "/srv/www/dashboard/phpmyadmin"
    noroot wget https://files.phpmyadmin.net/phpMyAdmin/4.8.5/phpMyAdmin-4.8.5-all-languages.zip -O phpmydmin.zip
    noroot unzip phpmyadmin.zip
fi