#!/bin/bash

noroot() {
    sudo -EH -u "vagrant" "$@";
}

if [[ ! -d "/srv/www/dashboard/public_html/phpmyadmin" ]]; then
    mkdir -p "/srv/www/dashboard/public_html/phpmyadmin"
    cd "/srv/www/dashboard/public_html/phpmyadmin"
    echo "extracting phpMyAdmin-4.8.5-all-languages"
    wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.zip -O phpmyadmin.zip
    unzip phpmyadmin.zip -d "/srv/www/dashboard/public_html/phpmyadmin"
    mv phpMyAdmin-4.9.0.1-all-languages/* "/srv/www/dashboard/public_html/phpmyadmin"
    rm -rf phpMyAdmin-4.9.0.1-all-languages
    rm phpmyadmin.zip
else
    echo "phpMyAdmin already installed."
fi
