#!/usr/bin/bash
set -m

path="/home/$USER_PROFILE/rplusdevops/$ENV_FOLDER"
jump="ssh -tt  $JUMP_SERVER"

version1_raw=$($jump "cat ~/.templates/README.md" | grep -E "Version:\s*[0-9.]*")
num1=$(echo "$version1_raw" | awk '{print $2}')

version2_raw=$(cat /home/ftedev/.templates/README.md | grep -E "Version:\s*[0-9.]*") # Replace with the actual path
num2=$(echo "$version2_raw" | awk '{print $2}')

if [[ "$num1" = "$num2" ]]; then
    echo "Version is the same in version $num1, please continue to the next process"
else
    echo "Copying new version '$num1' ............"
    scp -r /home/ftedev/.templates "$JUMP_SERVER":/home/"$USER_PROFILE"/
fi

if $jump [ -d /tmp/$NEW_SERVICE-log-push ]; then
    echo "Folder $NEW_SERVICE-log-push Already Exist"
else
    $jump "mkdir /tmp/$NEW_SERVICE-log-push"
fi

if $jump [ -d "$NEW_FILE" ]; then
    echo "Folder $NEW_FILE Already Exist"
else
    $jump "cp .templates/$COPY_FROM_FILE $path/build/$NEW_FILE"
fi

$jump "sed -i 's/\[ENV\]/$ENVIRONMENT/g' $path/build/$NEW_FILE"
$jump "sed -i 's/\[SERVICE_NAME\]/$NEW_SERVICE/g' $path/build/$NEW_FILE"
$jump "sed -i 's/\[USER_PROFILE\]/$USER_PROFILE/g' $path/build/$NEW_FILE"
$jump "sed -i 's/\[BRANCH_DEVOPS\]/$BRANCH_DEVOPS/g' $path/build/$NEW_FILE"
$jump "sed -i 's/\[ENV_FOLDER\]/$ENV_FOLDER/g' $path/build/$NEW_FILE"

if $jump [ -d "$NEW_FOLDER" ]; then
    echo "Folder $NEW_FOLDER Already Exist"
else
    $jump "cp -r .templates/$COPY_FROM_FOLDER $path/$NEW_FOLDER"
    if [ -d "$NEW_SERVICE-deployment.yaml" ]; then
        echo "Folder $NEW_SERVICE-deployment.yaml Already Exist"
    else
        $jump "mv $path/$NEW_FOLDER/template-deployment.yaml $path/$NEW_FOLDER/$NEW_SERVICE-deployment.yaml"
    fi
fi

if [ "$SECRET" = true ]; then
    $jump "cp .templates/secret-template.yaml $path/$NEW_FOLDER/secret-$NEW_SERVICE.yaml"
else
    echo "Cannot used secret"
fi

if [ "$HPA" = true ]; then
    $jump "cp .templates/hpa.yaml $path/$NEW_FOLDER/hpa-$NEW_SERVICE.yaml"
else
    echo "Cannot used HPA"
fi

$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[ENV\]/$ENVIRONMENT/g' {} +"
$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[SERVICE_NAME\]/$NEW_SERVICE/g' {} +"
$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[PORT\]/$PORT_SERVICE/g' {} +"
$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[SLB\]/$SLB_SERVICE/g' {} +"
$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[BRANCH_BITBUCKET\]/$BRANCH_BITBUCKET/g' {} +"
$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[USER_PROFILE\]/$USER_PROFILE/g' {} +"
$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[ENV_FOLDER\]/$ENV_FOLDER/g' {} +"
$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[JUMP_SERVER\]/$JUMP_SERVER/g' {} +"
$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[CPU_LIMIT\]/$CPU_LIMIT/g' {} +"
$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[MEM_LIMIT\]/$MEM_LIMIT/g' {} +"

# Create Job and View

cd /etc/ansible/templates

if [ "$ENV_FOLDER" = "development" ]; then
    cp /etc/ansible/templates/development/dev-template-job-build.xml /etc/ansible/templates/development/$ENVIRONMENT/$ENVIRONMENT-$NEW_SERVICE-job-build.xml
    cp /etc/ansible/templates/development/dev-template-job-k8s.xml /etc/ansible/templates/development/$ENVIRONMENT/$ENVIRONMENT-$NEW_SERVICE-job-k8s.xml
    find /etc/ansible/templates/development/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[JUMP_SERVER\]/$JUMP_SERVER/g" {} +
    find /etc/ansible/templates/development/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[USER_PROFILE\]/$USER_PROFILE/g" {} +
    find /etc/ansible/templates/development/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[ENV\]/$ENVIRONMENT/g" {} +
    find /etc/ansible/templates/development/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[SERVICE_NAME\]/$NEW_SERVICE/g" {} +
    find /etc/ansible/templates/development/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[BRANCH_DEVOPS\]/$BRANCH_DEVOPS/g" {} +
    find /etc/ansible/templates/development/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[BRANCH_BITBUCKET\]/$BRANCH_BITBUCKET/g" {} +
    find /etc/ansible/templates/development/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[ENV_FOLDER\]/$ENV_FOLDER/g" {} +
else
    cp /etc/ansible/templates/production/prod-template-job-build.xml /etc/ansible/templates/production/$ENVIRONMENT/$ENVIRONMENT-$NEW_SERVICE-job-build.xml
    cp /etc/ansible/templates/production/prod-template-job-k8s.xml /etc/ansible/templates/production/$ENVIRONMENT/$ENVIRONMENT-$NEW_SERVICE-job-k8s.xml
    find /etc/ansible/templates/production/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[JUMP_SERVER\]/$JUMP_SERVER/g" {} +
    find /etc/ansible/templates/production/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[USER_PROFILE\]/$USER_PROFILE/g" {} +
    find /etc/ansible/templates/production/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[ENV\]/$ENVIRONMENT/g" {} +
    find /etc/ansible/templates/production/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[ENV_FOLDER\]/$ENV_FOLDER/g" {} +
    find /etc/ansible/templates/production/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[SERVICE_NAME\]/$NEW_SERVICE/g" {} +
    find /etc/ansible/templates/production/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[BRANCH_DEVOPS\]/$BRANCH_DEVOPS/g" {} +
    find /etc/ansible/templates/production/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[BRANCH_BITBUCKET\]/$BRANCH_BITBUCKET/g" {} +
fi

if [ "$ENV_FOLDER" = "development" ]; then
    ansible-playbook /etc/ansible/templates/dev-ansible-create-job-jenkins.yaml
else
    ansible-playbook /etc/ansible/templates/ansible-create-job-jenkins.yaml
fi
