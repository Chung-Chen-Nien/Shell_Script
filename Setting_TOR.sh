#!/bin/bash

echo "Setting TOR1"
sshpass -p password ssh -o StrictHostKeyChecking=no root@192.168.42.156 "cd /root/sdk/R1165-J0003-01_V2.1.12_Shenzhou_SDK/ ; ./cls_shell exit ; ./auto_load_user.sh -d -m "1-30:Copper_2x100G;31-32:Copper_1x40G" ; ./cls_shell ps "

sleep 3

echo "Setting TOR2"
sshpass -p password ssh -o StrictHostKeyChecking=no root@192.168.42.157 "cd /root/sdk/R1165-J0003-01_V2.1.12_Shenzhou_SDK/ ; ./cls_shell exit ; ./auto_load_user.sh -d -m "1-30:Copper_2x100G;31-32:Copper_1x40G" ; ./cls_shell ps "

sleep 3
