#!/bin/bash
DOMAIN=$1
SITE_ESCAPED=`echo ${SITE} | sed 's/\./\\\\./g'`
REPO=$2
BRANCH=$3
VM_DIR=$4
SKIP_PROVISIONING=$5
PATH_TO_SITE=${VM_DIR}
SITE_NAME=${SITE}

SANDBOX_CONFIG=/vagrant/sandbox-custom.yml

noroot() {
    sudo -EH -u "vagrant" "$@";
}

# Takes 2 values, a key to fetch a value for, and an optional default value
# e.g. echo `get_config_value 'key' 'defaultvalue'`
get_config_value() {
    local value=`cat ${SANDBOX_CONFIG} | shyaml get-value sites.${SITE_ESCAPED}.custom.${1} 2> /dev/null`
    echo ${value:-$2}
}

echo `get_config_value`

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

