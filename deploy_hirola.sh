#!/usr/bin/env bash

set -o errexit
set -o pipefail
# set -o nounset
# set -o xtrace

install_dependencies () {
    sudo apt-get -y upgrade
    sudo apt-get -y update
    sudo apt-get install -y python3-pip
    sudo apt-get install -y python-virtualenv
}

get_var() {
  local name="$1"

  curl -s -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/attributes/${name}"
}

install_and_start_repo () {
    BRANCH="$(get_var "circleBranch")" 
    cd ~
    virtualenv --python=python3 hi-venv
    source ~/hi-venv/bin/activate
    git clone -b ${BRANCH} https://github.com/JamesKirkAndSpock/Hirola
    pip install -r ~/Hirola/hirola/requirements.txt
    export IP_ADDRESS="$(get_var "ipAddress")"
    nohup python3 ~/Hirola/hirola/manage.py runserver 0.0.0.0:8000 &
}

main () {
    install_dependencies
    install_and_start_repo
}

main "$@"
