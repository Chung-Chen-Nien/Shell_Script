#!/bin/bash

SSH="ssh -o StrictHostKeyChecking=no"
IPMI="ipmitool -Uadmin -Padmin -H"

ifconfig eth1 10.0.0.2
./push_CarbonNDK-primary_keg.sh 10.0.0.1
sleep 2

$SSH -t root@10.0.0.1 "ip a|grep "global eth0"|awk '{print $2}'|cut -d '/' -f1"
