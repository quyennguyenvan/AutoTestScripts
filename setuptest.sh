#!/bin/bash
if grep "$(whoami) ALL=(ALL) NOPASSWD:ALL" /etc/sudoers
then
    echo
else
    sudo echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
fi
touch logs.txt
chmod 755 logs.txt
exec > logs.txt 2>&1
OUTPUT=$(cat /etc/*release)
if echo $OUTPUT | grep -q "Ubuntu 18.04" ; then
    apt install -y -qq wget curl
elif echo $OUTPUT | grep -q "Ubuntu 20.04" ; then
    apt install -y -qq wget curl
elif echo $OUTPUT | grep -q "Ubuntu 22.04"; then
    apt install -y -qq wget curl 
fi
echo "Server release: $OUTPUT"
#Download the install master script

curl --silent -o  mattertest.sh "https://raw.githubusercontent.com/quyennguyenvan/AutoTestScripts/main/mattertest.sh"  2>/dev/null
chmod 755 mattertest.sh



./mattertest.sh $@