#!/bin/bash
if grep "$(whoami) ALL=(ALL) NOPASSWD:ALL" /etc/sudoers
then
    echo
else
    sudo echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
fi
sudo apt-get remove python3-apt -y
sudo apt-get install python3-apt -y
sudo apt autoremove -y

./setupOTBR.sh -if wlan0 -s &&
./setupOTBR.sh -i &&
rm -f /home/$(whoami)/.cache/tools/images/* /tmp/raspbian-ubuntu/*



