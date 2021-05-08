#!/bin/bash

sandbox_config="/srv/.global/custom.yml"

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
    noroot openssl genrsa -out "/srv/certificates/ca/ca.key" 4096 &>/dev/null
    noroot openssl req -x509 -new -nodes -key "/srv/certificates/ca/ca.key" -sha256 -days 365 -out "/srv/certificates/ca/ca.crt" -subj "/CN=Sandbox Internal CA" &>/dev/null
fi

for domain in `get_sites`; do
    get_site_provision() {
      local value=`cat ${sandbox_config} | shyaml get-value sites.${domain}.provision 2> /dev/null`
      echo ${value:-$@}
    }

    provision=`get_site_provision`

    if [[ "True" == ${provision} ]]; then
        if [[ ! -d "/srv/certificates/${domain}" ]]; then
            mkdir -p "/srv/certificates/${domain}"
            cp "/srv/config/certificates/domain.ext" "/srv/certificates/${domain}/${domain}.ext"
            sed -i -e "s/{{DOMAIN}}/${domain}/g" "/srv/certificates/${domain}/${domain}.ext"

            noroot openssl genrsa -out "/srv/certificates/${domain}/${domain}.key" 4096 &>/dev/null
            noroot openssl req -new -key "/srv/certificates/${domain}/${domain}.key" -out "/srv/certificates/${domain}/${domain}.csr" -subj "/CN=*.${domain}.test" &>/dev/null
            noroot openssl x509 -req -in "/srv/certificates/${domain}/${domain}.csr" -CA "/srv/certificates/ca/ca.crt" -CAkey "/srv/certificates/ca/ca.key" -CAcreateserial -out "/srv/certificates/${domain}/${domain}.crt" -days 365 -sha256 -extfile "/srv/certificates/${domain}/${domain}.ext" &>/dev/null
        fi
    fi
done

if [[ ! -d "/srv/certificates/dashboard" ]]; then
  mkdir -p "/srv/certificates/dashboard"
  cp "/srv/config/certificates/domain.ext" "/srv/certificates/dashboard/dashboard.ext"
  sed -i -e "s/{{DOMAIN}}/dashboard/g" "/srv/certificates/dashboard/dashboard.ext"
  noroot openssl genrsa -out "/srv/certificates/dashboard/dashboard.key" 4096 &>/dev/null
  noroot openssl req -new -key "/srv/certificates/dashboard/dashboard.key" -out "/srv/certificates/dashboard/dashboard.csr" -subj "/CN=*.dashboard.test" &>/dev/null
  noroot openssl x509 -req -in "/srv/certificates/dashboard/dashboard.csr" -CA "/srv/certificates/ca/ca.crt" -CAkey "/srv/certificates/ca/ca.key" -CAcreateserial -out "/srv/certificates/dashboard/dashboard.crt" -days 365 -sha256 -extfile "/srv/certificates/dashboard/dashboard.ext" &>/dev/null
fi
