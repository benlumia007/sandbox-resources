#!/bin/bash
domain=${domain}
sandbox_config=/vagrant/sandbox-custom.yml

get_config_value() {
    local value=`cat ${sandbox_config} | shyaml get-value sites.${SITE_ESCAPED}.custom.${1} 2> /dev/null`
    echo ${value:-$2}
}
noroot() {
    sudo -EH -u "vagrant" "$@";
}

if [[ ! -d "/vagrant/certificates/ca" ]]; then
    noroot mkdir -p "/vagrant/certificates/ca"
    noroot openssl genrsa -out "/vagrant/certificates/ca/ca.key" 4096
    noroot openssl req -x509 -new -nodes -key "/vagrant/certificates/ca/ca.key" -sha256 -days 3650 -out "/vagrant/certificates/ca/ca.crt" -subj "/CN=Sandbox Internal CA"
    a2enmod ssl headers rewrite
else
    echo "a root certificate of ca has been generated."
fi

if [[ ! -d "/vagrant/certificates/${domain}" ]]; then
    mkdir -p "/vagrant/certificates/${domain}"
    cp "/srv/config/certificates/domain.ext" "/vagrant/certificates/${domain}/${domain}.ext"
    sed -i -e "s/{{DOMAIN}}/${domain}/g" "/vagrant/certificates/${domain}/${domain}.ext"

    noroot openssl genrsa -out "/vagrant/certificates/${domain}/${domain}.key" 4096
    noroot openssl req -new -key "/vagrant/certificates/${domain}/${domain}.key" -out "/vagrant/certificates/${domain}/${domain}.csr" -subj "/CN=${domain}"
    noroot openssl x509 -req -in "/vagrant/certificates/${domain}/${domain}.csr" -CA "/vagrant/certificates/ca/ca.crt" -CAkey "/vagrant/certificates/ca/ca.key" -CAcreateserial -out "/vagrant/certificates/${domain}/${domain}.crt" -days 3650 -sha256 -extfile "/vagrant/certificates/${domain}/${domain}.ext"
    sed -i '/certificate/s/^#//g' /etc/apache2/sites-available/${domain}.conf
else
    echo "${domain} has already been generated."
fi