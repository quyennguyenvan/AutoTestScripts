#!/bin/bash
exec > logs.txt 2>&1

OTBR_WRKSPC="/home/ubuntu/ot-br-posix"

declare OTBR_AGENT_ENABLED=enabled
declare OTBR_WEB_ENABLED=enabled
declare COMPLIANCE_COMMIT_ID=f0bd216

declare OTBR_SERVICES_NAME=otbr
declare OTBR_AGENT_SERVICES="otbr-agent.service"
declare LINES="=============================================================================="
#running the fix missing apt_pgk and update

echo $LINES
echo "AUTOMATION TESTING IMAGES AND OTBR SERVICES TOOLS"
echo $LINES

echo $LINES
echo "Trying enable services OTBR"
sudo systemctl enable otbr-agent
sudo systemctl start otbr-agent
sudo systemctl enable otbr-web
sudo systemctl start otbr-web
echo $LINES

if sudo systemctl status "$OTBR_AGENT_SERVICES" 2> /dev/null | grep "active"; then
    echo $LINES
    echo "OTBR services is actived"
    echo $LINES

else
    echo $LINES
    echo "OTBR service not available"
    echo "install depends package"
    echo $LINES

    sudo apt-get remove python3-apt -y
    sudo apt-get install python3-apt -y
    sudo apt autoremove -y
    sudo apt install git -y

    echo "otbr services is not found or exists"

    echo "access to otbr sources code to check and install manual"

    #checkout source code
    echo "checkout source code to vailid commitID"
    git -C $OTBR_WRKSPC checkout $COMPLIANCE_COMMIT_ID
    git submodule update --init 

    echo "execution the setup OTBR"
    yes | ./setupOTBR.sh -if wlan0 -s  && yes | ./setupOTBR.sh -i

    echo "back to shell commander and test services"

    echo "enable the services of otbr"

    sudo systemctl enable otbr-agent
    sudo systemctl start otbr-agent
    sudo systemctl enable otbr-web
    sudo systemctl start otbr-web
fi

echo $LINES
echo "trying create the form network"

formTest=$(curl 'http://localhost/form_network' \
  -H 'Accept: application/json, text/plain, */*' \
  -H 'Accept-Language: en-US,en;q=0.9,vi;q=0.8,ja;q=0.7' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/json;charset=UTF-8' \
  -H 'Origin: http://localhost' \
  -H 'Referer: http://localhost/' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.66 Safari/537.36 Edg/103.0.1264.44' \
  --data-raw '{"networkKey":"00112233445566778899aabbccddeeff","prefix":"fd11:22::","defaultRoute":true,"extPanId":"1111111122222222","panId":"0x1234","passphrase":"j01Nme","channel":15,"networkName":"OpenThreadDemo"}' \
  --compressed \
  --insecure
  --vvv 2> /dev/null | grep 'result')


echo $LINES

echo "Network form result"

if echo $formTest | grep -q "successful" ; then

echo "OTBR services init successful"

else

echo "OTBR services init failed"

fi


echo "Sending report to notification hub"

curl --location --request POST 'notihub-1610877711.us-west-2.elb.amazonaws.com/v1/notifications' \
--header 'Content-Type: application/json' \
--data-raw '{
    "endpoint" : "teams",
    "body": {
        "title": "Image Testing Report",
        "message" : "Test with result $formTest"
    }
}'
echo "Finished test"

echo $LINES