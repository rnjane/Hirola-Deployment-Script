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
    python3 ~/Hirola/hirola/manage.py makemigrations front
    python3 ~/Hirola/hirola/manage.py migrate
#     echo "from django.contrib.auth.models import User; User.objects.create_superuser('user', 'user@example.com', 'password')" | python3 ~/Hirola/hirola/manage.py shell
    nohup python3 ~/Hirola/hirola/manage.py runserver 0:80 &
}

add_cron_job_to_crontab() {
    cat > cron_example <<'EOF'
0 14 * * 1-5 bash ~/telegram.sh
0 15 * * 5 bash ~/review.sh
EOF

    cat cron_example | crontab

    rm -rf cron_example
    echo "Cron job added to run the scripts"
}

add_telegram_file() {
    ENV="$(get_var "env")"
    echo "$ENV"
    if [ $ENV == "devops" ];then
        echo "Copying notification scripts."
        gsutil cp gs://compute-engine-overview-186809/hirola/telegram.sh ~/
        gsutil cp gs://compute-engine-overview-186809/hirola/review.sh ~/
        add_cron_job_to_crontab
    else
        echo "Cron jobs not added. Notification scripts not copied."
    fi
}

main () {
    install_and_start_repo
    add_telegram_file
}

main "$@"
