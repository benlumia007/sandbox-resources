#!/bin/bash

escaped=`echo ${domain} | sed 's/\./\\\\./g'`
sandbox_config=/vagrant/sandbox-custom.yml

get_sites() {
    local value=`cat ${sandbox_config} | shyaml keys sites 2> /dev/null`
    echo ${value:-$@}
}
domain=`get_sites`
echo "${domain}"