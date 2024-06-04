#!/usr/bin/zsh

PUSH_TIMESTAMP=$(date)

echo "\n$(cat ./README-HWC.md)\n\n$PUSH_TIMESTAMP" >>./log-push/wrapper.log

# Function to handle exceptions
handle_exception() {
    local exit_code=$?
    local error_message="$1"
    if [ $exit_code -ne 0 ]; then
        echo "Error: $error_message (Exit code: $exit_code)"
        # You can add any additional error handling logic here.
    else
        echo "Success: all folder success copy to jenkins"
    fi
}

# Wrap your code that may throw exceptions in a function
main() {
    # Your SCP command here
    sshpass -p "ftedev!@#" scp -r -J ftedev@149.129.219.106 ./secret-template.yaml ftedev@172.31.123.0:~/.templates || handle_exception "Failed to copy the file"
    sshpass -p "ftedev!@#" scp -r -J ftedev@149.129.219.106 ./template-build-pushcommit-beta-prod.sh ftedev@172.31.123.0:~/.templates/template-build-pushcommit.sh || handle_exception "Failed to copy the file"
    sshpass -p "ftedev!@#" scp -r -J ftedev@149.129.219.106 ./k8s-template-hwc ftedev@172.31.123.0:~/.templates || handle_exception "Failed to copy the file"
    sshpass -p "ftedev!@#" scp -r -J ftedev@149.129.219.106 ./k8s-template-vault-hwc ftedev@172.31.123.0:~/.templates || handle_exception "Failed to copy the file"
    sshpass -p "ftedev!@#" scp -r -J ftedev@149.129.219.106 ./k8s-template-beta-prod-hwc ftedev@172.31.123.0:~/.templates || handle_exception "Failed to copy the file"
    sshpass -p "ftedev!@#" scp -r -J ftedev@149.129.219.106 ./k8s-template-vault-beta-prod-hwc ftedev@172.31.123.0:~/.templates || handle_exception "Failed to copy the file"
    sshpass -p "ftedev!@#" scp -r -J ftedev@149.129.219.106 ./hpa.yaml ftedev@172.31.123.0:~/.templates || handle_exception "Failed to copy the file"
    sshpass -p "ftedev!@#" scp -r -J ftedev@149.129.219.106 ./README-HWC.md ftedev@172.31.123.0:~/.templates || handle_exception "Failed to copy the file"

    # Add more commands here if needed
}

# Call the main function and handle exceptions
main
handle_exception "Script failed"
