#!/usr/bin/zsh

function commit() {
    echo "Usage: $0 -v <new_version> -m <changelog_message>"
    exit 1
}

while getopts "v:m:" opt; do
    case $opt in
        v)
            new_version="$OPTARG"
            ;;
        m)
            changelog_message="$OPTARG"
            ;;
        *)
            echo "Usage: $0 -v <new_version> -m <changelog_message>"
            exit 1
            ;;
    esac
done

if [ -z "$new_version" ] || [ -z "$changelog_message" ]; then
    commit
fi

# Update the version
sed -i "s/Version: .*/Version: $new_version/" $HOME/repository/research/ALIYUN/README.md

# Add the message to the Changelog
# sed -i "/^--/a -- $changelog_message" $HOME/repository/research/README.md
echo "-- $changelog_message" >> $HOME/repository/research/ALIYUN/README.md

echo "Version updated to: $new_version"
echo "Changelog updated with message: $changelog_message"
