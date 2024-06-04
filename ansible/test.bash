#!/usr/bin/bash

strlenArgs="$(cat './listApp.txt' | wc -l)"

for ((i = 1; i <= $((strlenArgs)); i++)); do
    python3 ./jenkins-build.py -c ./config.yaml \
        -j migrate-hwc \
        -p SECRET=false \
        -p HPA=false \
        -p SERVERLESS=false \
        -p USER_PROFILE=dev-newrplus \
        -p JUMP_SERVER=dev-newrplus@110.239.67.83 \
        -p PORT="2222" \
        -p BRANCH_DEVOPS=dev-huawei \
        -p ENV_FOLDER=development \
        -p BRANCH_BITBUCKET=development \
        -p NEW_FILE="dev-$(cat './listApp.txt' | sed -n $((i))p)-pushcommit.sh" \
        -p COPY_FROM_FOLDER=k8s-template-vault-hwc \
        -p NEW_FOLDER="$(cat './listApp.txt' | sed -n $((i))p)" \
        -p NEW_SERVICE="$(cat './listApp.txt' | sed -n $((i))p)" \
        -p PORT_SERVICE="3000" \
        -p DOMAIN="rctiplus.com" \
        -p ENVIRONMENT=dev \
        -p DNS_NAME="dev-$(cat './listApp.txt' | sed -n $((i))p).rctiplus.com" \
        -p CPU_LIMIT="500m" \
        -p MEM_LIMIT=1024Mi \
        -p VIEW=DEV
done
