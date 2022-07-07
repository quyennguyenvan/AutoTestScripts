import os
import subprocess
import shlex
import time
import logging
from pathlib import Path

logging.basicConfig(format='%(asctime)s %(process)d %(levelname)s %(name)s %(message)s', level=logging.INFO,filename="log.txt")
logger = logging.getLogger(__name__)
logger.info('Logger init ... OK')

OTBR_AGENT_ENABLED:bool = True
OTBR_WEB_ENABLED:bool = True
COMPLIANCE_COMMIT_ID:str = "f0bd216"
OTBR_AGENT_SERVICES:str = "otbr-agent.service"
OTBR_WEB_SERVICES:str = "otbr-web.service"
LINER:str = "========================================================================================"
ENABLE_SETUP_ENV:bool = True
SOURCE_SETUP_DIC_PATH:str = "/home/ubuntu/ot-br-posix"

#create function interactive with command line
def executioner( command, component, do_exit=0):
    try:
        count = 0
        while True:
            res = subprocess.call(shlex.split(command))
            if res != 0:
                count = count + 1
                stdOut(component + ' failed, trying again, try number: ' + str(count), 0)
                if count == 3:
                    stdOut(component + ' failed.', do_exit)
                    return False
            else:
                stdOut(component + ' successful.', 0)
                break
        return True
    except:
        return 0

def stdOut(message, do_exit=0):
        print("\n\n")
        print(("[" + time.strftime(
            "%m.%d.%Y_%H-%M-%S") + "] #########################################################################\n"))
        print(("[" + time.strftime("%m.%d.%Y_%H-%M-%S") + "] " + message + "\n"))
        print(("[" + time.strftime(
            "%m.%d.%Y_%H-%M-%S") + "] #########################################################################\n"))

        if do_exit:
            os._exit(0)

def servicesStatusCheck(serviceName:str, status:str = "active"):
    strBuilder = f"sudo systemctl status {serviceName} 2> /dev/null | grep -Fq {status}"
    result = executioner(strBuilder, strBuilder, 0)
    logging.info(f"service: {serviceName} check with result: {result}")
    return result

def servicesVersionCheck(serviceName:str):
    strBuilder = f"{serviceName} --version"
    result = executioner(strBuilder, strBuilder, 0)
    logging.info(f"service: {serviceName} check version with result: {result}")
    return result

def curlOtbrService():

    pass

if __name__ == "__main__":
    
    print('trigger test')
    print('Checking services is available')
    
    otbrCheck = servicesStatusCheck(OTBR_AGENT_SERVICES)
    
    if otbrCheck:
        curlOtbrService()
    else:
        print('Services OTBR not exists or not Active already')
        if ENABLE_SETUP_ENV:
            print(f'''Install enviroment
            {LINER}
            ''')
            executioner('sudo apt-get remove python3-apt -y','sudo apt-get remove python3-apt -y')
            executioner('sudo apt-get install python3-apt -y','sudo apt-get install python3-apt -y')
            executioner('sudo apt autoremove -y','sudo apt autoremove -y')
            executioner('sudo apt install git -y','sudo apt install git -y')
            print(f'''
            {LINER}
            Environment setup done !
            {LINER}
            ''')
        
        print(f'{LINER}')
        
        cmd = f"sudo git -C {SOURCE_SETUP_DIC_PATH} checkout {COMPLIANCE_COMMIT_ID}"
        
        print('check out source code')
        
        gitcheckout = executioner(cmd,cmd,0)

        if gitcheckout:

            print(f'{LINER}')
            
            print('Setup OTBR services')
            
            print(f'{LINER}')
            
            cmd = './setupOTBR.sh -if wlan0 -s && ./setupOTBR.sh -i'
            
            setupOtbr = executioner(cmd,cmd,0)
            if setupOtbr:
                executioner('sudo systemctl enable otbr-agent','sudo systemctl enable otbr-agent')
                executioner('sudo systemctl enable otbr-web','sudo systemctl enable  otbr-web')
                executioner('sudo systemctl start  otbr-agent','sudo systemctl start  otbr-agent')
                executioner('sudo systemctl start  otbr-web','sudo systemctl start  otbr-web')

            print(f'{LINER}')
            print('Finished setup OTBR services')


    print(f'{LINER}')
    print('Trying trigger services')
    curlOtbrService()




