#!/bin/bash
#exec > logstest.txt 2>&1
if grep "$(whoami) ALL=(ALL) NOPASSWD:ALL" /etc/sudoers
then
    echo
else
    sudo echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
fi
OTBR_WRKSPC="/home/ubuntu/ot-br-posix"
CHIPTOOL_WRKSPC="/home/ubuntu/connectedhomeip"
HOSTNAME=$(hostname)
declare COMPLIANCE_COMMIT_ID=f0bd216
declare OTBR_AGENT_SERVICES="otbr-agent.service"
declare LINES="==============================================="
#running the fix missing apt_pgk and update

#create the fucntion
notif () {
    msg=$1
    curl --location --request POST 'http://notihub-1610877711.us-west-2.elb.amazonaws.com/v1/notifications' \
        --header 'Content-Type: application/json' \
        --data-raw '{  "endpoint" : "teams", "body": {  "title": "Image Testing Report",  "message" : "'"$msg"'" } }'

}

msg(){

    message=$1
    echo $LINES
    notif "$HOSTNAME - $message"
    echo "\n"
    echo "$message"
    echo $LINES
}

envCheck(){
    command=$1
    requirecheck=$2
    message=$3

    echo "command validation: ${command}"
    
    [[ $command 2> /dev/null | grep "${requirecheck}" ]] && msg "${message} sucsscessd" || msg "${message} not sucsscessd"
}

rcpcheckf(){
    [[ ls /dev/ttyACM0 2> /dev/null | grep "ACM0" ]] && msg "RCP device found" || msg "RCP device not found"
}

echo $LINES
echo "AUTOMATION TESTING IMAGES AND OTBR SERVICES TOOLS"
echo "HOSTNAME: ${HOSTNAME}"
echo $LINES

echo "RCP device checking"
rcpcheckf 

#testing chiptool
#neet to check ?
msg 'Chiptool ENV validation'
envCheck "source ${CHIPTOOL_WRKSPC}/scripts/activate.sh" "good" "Chiptool - env"

msg 'OTBR services validation'
[[ sudo systemctl status "$OTBR_AGENT_SERVICES" 2> /dev/null | grep "active" ]] && msg "OTBR services is actived" ||  msg "OTBR service not available"

msg "Trying create the form network"

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


echo "Created network form result"

[[ echo $formTest | grep -q "successful" ]] && \
    msg "Form network for OTBR services init successful" \
    echo  "The dataset otbr network: $(sudo ot-ctl dataset active -x)" \
|| msg "Form network for OTBR services init failed"

msg "Finished test"
