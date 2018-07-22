#!/usr/bin/env bash

set -o errexit
set -o pipefail
# set -o nounset
# set -o xtrace

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
    ENVIRONMENT="$(get_var "environment")"
    export IP_ADDRESS="$(get_var "ipAddress")"
    export HOST="$(get_var "host")"
    export DATABASE_NAME="$(get_var "databaseName")"
    export USER="$(get_var "user")"
    export PASSWORD="$(get_var "password")"
    export DJANGO_SETTINGS_MODULE=hirola.settings.${ENVIRONMENT}
    export POSTGRES_IP="$(get_var "postgresIp")"
    export SECRET_KEY="$(sudo openssl rand -hex 64)"
    export GS_BUCKET_NAME="$(get_var "gsBucketName")"
    export GS_BUCKET_URL="$(get_var "gsBucketURL")"
    export CACHE_IP="$(get_var "cacheIP")"
    export CACHE_PORT="$(get_var "cachePort")"
    python3 ~/Hirola/hirola/manage.py makemigrations front
    python3 ~/Hirola/hirola/manage.py migrate
    memcached -d
    # echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'hirola77')" | python3 ~/Hirola/hirola/manage.py shell
    nohup python3 ~/Hirola/hirola/manage.py runserver 0:80 &
}


main () {
    install_and_start_repo
}

main "$@"
