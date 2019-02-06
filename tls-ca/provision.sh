#!/bin/bash
domain=${1}
escaped=`echo ${domain} | sed 's/\./\\\\./g'`
sandbox_config="/vagrant/sandbox-custom.yml"

get_config_value() {
    local value=`cat ${sandbox_config} | shyaml get-value sites.${escaped}.custom.${1} 2> /dev/null`
    echo ${value:-$2}
}

echo "${domain}"