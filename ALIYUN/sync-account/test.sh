#!/usr/bin/zsh

find . -type f -exec sed -i 's/\[ENV\]/dev/g' {} +
find . -type f -exec sed -i 's/\[SERVICE_NAME\]/sync-account/g' {} +
find . -type f -exec sed -i 's/\[PORT\]/8008/g' {} +
find . -type f -exec sed -i 's/\[SLB\]/test/g' {} +
find . -type f -exec sed -i 's/\[BRANCH_BITBUCKET\]/master/g' {} +
find . -type f -exec sed -i 's/\[USER_PROFILE\]/dev-newrplus/g' {} +
find . -type f -exec sed -i 's/\[ENV_FOLDER\]/development/g' {} +
find . -type f -exec sed -i 's/\[JUMP_SERVER\]/dev-newrplus@149.129.219.106/g' {} +
