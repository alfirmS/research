#!/usr/bin/bash
set -m

path="/home/$USER_PROFILE/rplusdevops/$ENV_FOLDER"
jump="ssh -tt -p 2222 $JUMP_SERVER"

version1_raw=$($jump "cat ~/.templates/README-HWC.md" | grep -E "Version:\s*[0-9.]*")
num1=$(echo "$version1_raw" | awk '{print $2}')

version2_raw=$(cat /home/ftedev/.templates/README-HWC.md | grep -E "Version:\s*[0-9.]*") # Replace with the actual path
num2=$(echo "$version2_raw" | awk '{print $2}')

if [[ "$num1" = "$num2" ]]; then
    echo "Version is the same in version $num1, please continue to the next process"
else
    echo "Copying new version $num1 ............"
    scp -r -P $PORT /home/ftedev/.templates "$JUMP_SERVER":/home/"$USER_PROFILE"/
fi

if $jump [ -d /tmp/$NEW_SERVICE-log-push ]; then
    echo "Folder $NEW_SERVICE-log-push Already Exist"
else
    $jump "mkdir /tmp/$ENVIRONMENT-$NEW_SERVICE-log-push"
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

if [ "$SERVERLESS" = true ]; then
    $jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[SERVERLESS\]/on/g' {} +"
else
    $jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[SERVERLESS\]/off/g' {} +"
fi

if [ "$DOMAIN" == "rctiplus.com" ]; then
    $jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[ELB_ID\]/$ELBID_RCTIPLUS/g' {} +"
    $jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[ELB_IP\]/$IP_RCTIPLUS/g' {} +"
    $jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[CERT_TLS\]/$CERTTLS_RCTIPLUS/g' {} +"
    $jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[TLS_NAME\]/$TLSNAME_RCTIPLUS/g' {} +"
elif [ "$DOMAIN" == "rctiplus.id" ]; then
    $jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[ELB_ID\]/$ELBID_RCTIPLUSID/g' {} +"
    $jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[ELB_IP\]/$IP_RCTIPLUSID/g' {} +"
    $jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[CERT_TLS\]/$CERTTLS_RCTIPLUSID/g' {} +"
    $jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[TLS_NAME\]/$TLSNAME_RCTIPLUSID/g' {} +"
else
    $jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[ELB_ID\]/$ELBID_MNCPLUS/g' {} +"
    $jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[ELB_IP\]/$IP_MNCPLUS/g' {} +"
    $jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[CERT_TLS\]/$CERTTLS_MNCPLUS/g' {} +"
    $jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[TLS_NAME\]/$TLSNAME_MNCPLUS/g' {} +"
fi

$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[ENV\]/$ENVIRONMENT/g' {} +"
$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[SERVICE_NAME\]/$NEW_SERVICE/g' {} +"
$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[PORT\]/$PORT_SERVICE/g' {} +"
$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[BRANCH_BITBUCKET\]/$BRANCH_BITBUCKET/g' {} +"
$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[USER_PROFILE\]/$USER_PROFILE/g' {} +"
$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[ENV_FOLDER\]/$ENV_FOLDER/g' {} +"
$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[JUMP_SERVER\]/$JUMP_SERVER/g' {} +"
$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[CPU_LIMIT\]/$CPU_LIMIT/g' {} +"
$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[MEM_LIMIT\]/$MEM_LIMIT/g' {} +"
$jump "find $path/$NEW_FOLDER -type f -exec sed -i 's/\[DNS_NAME\]/$DNS_NAME/g' {} +"

# Create Job and View

cd /etc/ansible/templates

if [ "$ENV_FOLDER" = "development" ]; then
    cp /etc/ansible/templates-hwc/development/dev-template-job-build.xml /etc/ansible/templates-hwc/development/$ENVIRONMENT/$ENVIRONMENT-$NEW_SERVICE-job-build.xml
    cp /etc/ansible/templates-hwc/development/dev-template-job-k8s.xml /etc/ansible/templates-hwc/development/$ENVIRONMENT/$ENVIRONMENT-$NEW_SERVICE-job-k8s.xml
    find /etc/ansible/templates-hwc/development/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[JUMP_SERVER\]/$JUMP_SERVER/g" {} +
    find /etc/ansible/templates-hwc/development/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[USER_PROFILE\]/$USER_PROFILE/g" {} +
    find /etc/ansible/templates-hwc/development/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[ENV\]/$ENVIRONMENT/g" {} +
    find /etc/ansible/templates-hwc/development/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[SERVICE_NAME\]/$NEW_SERVICE/g" {} +
    find /etc/ansible/templates-hwc/development/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[BRANCH_DEVOPS\]/$BRANCH_DEVOPS/g" {} +
    find /etc/ansible/templates-hwc/development/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[BRANCH_BITBUCKET\]/$BRANCH_BITBUCKET/g" {} +
    find /etc/ansible/templates-hwc/development/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[ENV_FOLDER\]/$ENV_FOLDER/g" {} +
else
    cp /etc/ansible/templates-hwc/production/prod-template-job-build.xml /etc/ansible/templates-hwc/production/$ENVIRONMENT/$ENVIRONMENT-$NEW_SERVICE-job-build.xml
    cp /etc/ansible/templates-hwc/production/prod-template-job-k8s.xml /etc/ansible/templates-hwc/production/$ENVIRONMENT/$ENVIRONMENT-$NEW_SERVICE-job-k8s.xml
    find /etc/ansible/templates-hwc/production/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[JUMP_SERVER\]/$JUMP_SERVER/g" {} +
    find /etc/ansible/templates-hwc/production/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[USER_PROFILE\]/$USER_PROFILE/g" {} +
    find /etc/ansible/templates-hwc/production/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[ENV\]/$ENVIRONMENT/g" {} +
    find /etc/ansible/templates-hwc/production/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[ENV_FOLDER\]/$ENV_FOLDER/g" {} +
    find /etc/ansible/templates-hwc/production/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[SERVICE_NAME\]/$NEW_SERVICE/g" {} +
    find /etc/ansible/templates-hwc/production/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[BRANCH_DEVOPS\]/$BRANCH_DEVOPS/g" {} +
    find /etc/ansible/templates-hwc/production/$ENVIRONMENT -type f -name "*${NEW_SERVICE}*" -exec sed -i "s/\[BRANCH_BITBUCKET\]/$BRANCH_BITBUCKET/g" {} +
fi

if [ "$ENV_FOLDER" = "development" ]; then
    ansible-playbook /etc/ansible/templates-hwc/dev-ansible-create-job-jenkins.yaml
else
    ansible-playbook /etc/ansible/templates-hwc/ansible-create-job-jenkins.yaml
fi
