#!/bin/bash
if grep "$(whoami) ALL=(ALL) NOPASSWD:ALL" /etc/sudoers
then
    echo
else
    sudo echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
fi

#env setup

# echo "Starting install requriement env needed"
# sudo apt-get remove python3-apt -y
# sudo apt-get install python3-apt -y
# sudo apt autoremove -y
# echo "Finished install requriement env needed"
touch logssetup.txt
chmod 755 logssetup.txt
exec > logssetup.txt 2>&1

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
#setup crontab after reboot  for mattertest after running firstrun.sh
curl --silent -o  mattertest.sh "https://raw.githubusercontent.com/quyennguyenvan/AutoTestScripts/main/mattertest.sh"  2>/dev/null
chmod +x mattertest.sh
sudo crontab -l > mattertest_job 
echo "@reboot sleep 60 && /home/ubuntu/scripts/mattertest.sh" >> mattertest_job 
sudo crontab mattertest_job
# sudo echo "@reboot /home/ubuntu/scripts/mattertest.sh" > /etc/cron.d/mattertest_job_test
# sudo chmod 600 /etc/cron.d/mattertest_job_test

#Trigger first run
./firstrun.sh $@

