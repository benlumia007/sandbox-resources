#!/bin/bash

sandbox_config="/vagrant/sandbox-custom.yml"

noroot() {
    sudo -EH -u "vagrant" "$@";
}

get_sites() {
    local value=`cat ${sandbox_config} | shyaml keys sites 2> /dev/null`
    echo ${value:-$@}
}

noroot() {
    sudo -EH -u "vagrant" "$@";
}

if [[ ! -d "/srv/certificates/ca" ]]; then
    noroot mkdir -p "/srv/certificates/ca"
    noroot openssl genrsa -out "/srv/certificates/ca/ca.key" 4096
    noroot openssl req -x509 -new -nodes -key "/srv/certificates/ca/ca.key" -sha256 -days 3650 -out "/srv/certificates/ca/ca.crt" -subj "/CN=Sandbox Internal CA"
else
    echo "a root certificate for ca has been generated."
fi

for domain in `get_sites`; do
    if [[ ! -d "/srv/certificates/${domain}" ]]; then
        mkdir -p "/srv/certificates/${domain}"
        cp "/srv/config/certificates/domain.ext" "/srv/certificates/${domain}/${domain}.ext"
        sed -i -e "s/{{DOMAIN}}/${domain}/g" "/srv/certificates/${domain}/${domain}.ext"

        noroot openssl genrsa -out "/srv/certificates/${domain}/${domain}.key" 4096
        noroot openssl req -new -key "/srv/certificates/${domain}/${domain}.key" -out "/srv/certificates/${domain}/${domain}.csr" -subj "/CN=*.${domain}.test"
        noroot openssl x509 -req -in "/srv/certificates/${domain}/${domain}.csr" -CA "/srv/certificates/ca/ca.crt" -CAkey "/srv/certificates/ca/ca.key" -CAcreateserial -out "/srv/certificates/${domain}/${domain}.crt" -days 3650 -sha256 -extfile "/srv/certificates/${domain}/${domain}.ext"
        sed -i '/certificate/s/^#//g' "/etc/apache2/sites-available/${domain}.conf"
    else
        echo "a certificate for ${domain}.test has been generated."
    fi
done

if [[ ! -d "/srv/certificates/dashboard" ]]; then
  mkdir -p "/srv/certificates/dashboard"
  cp "/srv/config/certificates/domain.ext" "/srv/certificates/dashboard/dashboard.ext"
  sed -i -e "s/{{DOMAIN}}/dashboard/g" "/srv/certificates/dashboard/dashboard.ext"
  noroot openssl genrsa -out "/srv/certificates/dashboard/dashboard.key" 4096
  noroot openssl req -new -key "/srv/certificates/dashboard/dashboard.key" -out "/srv/certificates/dashboard/dashboard.csr" -subj "/CN=*.dashboard.test"
  noroot openssl x509 -req -in "/srv/certificates/dashboard/dashboard.csr" -CA "/srv/certificates/ca/ca.crt" -CAkey "/srv/certificates/ca/ca.key" -CAcreateserial -out "/srv/certificates/dashboard/dashboard.crt" -days 3650 -sha256 -extfile "/srv/certificates/dashboard/dashboard.ext"
fi
