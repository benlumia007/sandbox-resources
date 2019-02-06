#!/bin/bash
domain=${1}
SITE_ESCAPED=`echo ${SITE} | sed 's/\./\\\\./g'`

sandbox_config=/vagrant/sandbox-custom.yml

get_config_value() {
    local value=`cat ${sandbox_config} | shyaml get-value sites.${SITE_ESCAPED}.custom.${1} 2> /dev/null`
    echo ${value:-$2}
}

echo "${domain}"

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

