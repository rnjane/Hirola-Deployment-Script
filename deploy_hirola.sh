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
    export IP_ADDRESS="$(get_var "ipAddress")"
    export HOST="$(get_var "host")"
    nohup python3 ~/Hirola/hirola/manage.py runserver 0:80 &
}


add_telegram_file() {
    gsutil cp gs://compute-engine-overview-186809/hirola/telegram.sh ~/
    gsutil cp gs://compute-engine-overview-186809/hirola/review.sh ~/
}

add_cron_job_to_crontab() {
  cat > cron_example <<'EOF'
0 18 * * 1-6 bash ~/telegram.sh
0 15 * * 5 bash ~/review.sh
EOF

cat cron_example | crontab

rm -rf cron_example
}


main () {
    install_and_start_repo
    add_telegram_file
    add_cron_job_to_crontab
}

main "$@"
