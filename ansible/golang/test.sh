#!/usr/bin/bash

go run ./jenkins.go \
	-job Auto%20Create%20Templates%20Deploy%20HWC \
	-params SECRET="false" HPA="false" SERVERLESS="false" \
	USER_PROFILE="ftedev" JUMP_SERVER="ftedev@$PRODHWC" BRANCH_DEVOPS="huawei" PORT=2222 \
	COPY_FROM_FILE="template-build-pushcommit.sh" ENVIRONMENT="production" ENV_FOLDER="production" \
	NEW_FILE="prod-test-build-pushcommit.sh" COPY_FROM_FOLDER="k8s-template-beta-prod-hwc" NEW_FOLDER="test" \
	NEW_SERVICE="test" PORT_SERVICE="3000" DOMAIN="rctiplus.com" \
	DNS_NAME="prod-test.rctiplus.com" VIEW="PROD" \
	CPU_LIMIT="2" MEM_LIMIT="512Mi"
