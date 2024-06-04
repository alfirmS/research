#!/bin/sh
# https://stackoverflow.com/questions/13716658/how-to-delete-all-commit-history-in-github

ENV='[ENV_FOLDER]'
USER='[USER_PROFILE]'
SERVICE='[SERVICE_NAME]'
REPO="/home/${USER}/rplusdevops"
BRANCH="[BRANCH_DEVOPS]"
COMMIT_TIMESTAMP=$(date +'%y-%m-%d %h:%m:%s %z')
CHANGE_LOG='SysLog DevOps'
DATELOG=$(date +'%Y-%m-%d-%H-%M-%S')

if [ ${ENV} = "development" ] || [ ${ENV} = "release-candidates" ]; then
    LOG="/tmp/${USER}-log-push/${DATELOG}.txt"
else
    LOG="/tmp/${SERVICE}-log-push/${DATELOG}.txt"
fi

GIT=$(which git)

if [ -d "/tmp/${SERVICE}-log-push" ]; then
    echo "Folder /tmp/${SERVICE}-log-push already exist"
else
    mkdir /tmp/${SERVICE}-log-push
fi

if [ ${ENV} = "development" ] || [ ${ENV} = "release-candidates" ]; then
    perl -pi.rollback -e "s/[ENV]:${SERVICE}-\K\d+/$&+1/ge" /home/${USER}/rplusdevops/${ENV}/${SERVICE}/${SERVICE}-deployment.yaml
    perl -pi.rollback -e "s/[ENV]:${SERVICE}-\K\d+/$&+1/ge" /home/${USER}/rplusdevops/${ENV}/${SERVICE}/Jenkinsfile
else
    perl -pi.rollback -e "s/[ENV]-${SERVICE}:\K\d+/$&+1/ge" /home/${USER}/rplusdevops/${ENV}/${SERVICE}/${SERVICE}-deployment.yaml
    perl -pi.rollback -e "s/[ENV]-${SERVICE}:\K\d+/$&+1/ge" /home/${USER}/rplusdevops/${ENV}/${SERVICE}/Jenkinsfile
fi

# Only proceed if we have a valid repo.
if [ ! -d ${REPO}/.git ]; then
    echo "${REPO} is not a valid git repo! Aborting..." >>${LOG}
    exit 0
else
    echo "${REPO} is a valid git repo! Proceeding..." >>${LOG}
fi

cd ${REPO}
${GIT} add ${ENV}/${SERVICE}/${SERVICE}-deployment.yaml >>${LOG}
${GIT} add ${ENV}/${SERVICE}/Jenkinsfile >>${LOG}
${GIT} commit -m "${SERVICE} automated commit  ${COMMIT_TIMESTAMP} ${CHANGE_LOG}" >>${LOG}
ssh-agent bash -c "ssh-add ~/.ssh/key-ssh/deploy; git push origin ${BRANCH}" >>${LOG}
