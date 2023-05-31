#!/bin/bash
if [[ ! -n "$1"  || ! -n "$2" || ! -n "$3" ]]; then
        echo " "
        echo "  Parameters are missing from your command."
        echo "  Usage: ./.sh BMC_IP HN_K2_IP SMC_ima"
        echo " "
else

BMC_IP=$1
HN_K2_IP=$2
SMC_ima=$3

SSH="ssh -o StrictHostKeyChecking=no"
IPMI="ipmitool -Uadmin -Padmin -H"


JBOG0_IP="$($IPMI $BMC_IP -b 10 -t 0x42 lan print 1|grep "IP Address"|tail -n 1|awk '{print $4}')"
sleep 3
JBOG1_IP="$($IPMI $BMC_IP -b 10 -t 0x44 lan print 1|grep "IP Address"|tail -n 1|awk '{print $4}')"
sleep 3
echo "JBOG0 SMC IP : $JBOG0_IP"
echo "JBOG1 SMC IP : $JBOG1_IP"

#for FRU_ID in 2 ;
#do
        JBOG0_K2_MAC="$($IPMI $JBOG0_IP fru print 2 | grep -A 1 "Mac_Port_2"|tail -n 1|awk '{print $4}')"
        JBOG1_K2_MAC="$($IPMI $JBOG1_IP fru print 2 | grep -A 1 "Mac_Port_2"|tail -n 1|awk '{print $4}')"
#done

echo "JBOG0 MAC : $JBOG0_K2_MAC"
echo "JBOG1 MAC : $JBOG1_K2_MAC"

JBOG0_K2_MAC="${JBOG0_K2_MAC:6:2}:${JBOG0_K2_MAC:8:2}:${JBOG0_K2_MAC:10:2}"
JBOG1_K2_MAC="${JBOG1_K2_MAC:6:2}:${JBOG1_K2_MAC:8:2}:${JBOG1_K2_MAC:10:2}"
#echo $JBOG0_K2_MAC
#echo $JBOG1_K2_MAC

#coap -O65001,0 -Y coaps+tcp://$HN_K2_IP/api-v1/debug/fs/local/var/cordite/dhcp.leases > /dev/null 2>&1

JBOG0_K2_IP="$(coap -O65001,0 -Y coaps+tcp://$HN_K2_IP/break-glass-v1/debug/fs/local/var/cordite/dhcp.leases | grep $JBOG0_K2_MAC | awk '{print $3}')"
JBOG1_K2_IP="$(coap -O65001,0 -Y coaps+tcp://$HN_K2_IP/break-glass-v1/debug/fs/local/var/cordite/dhcp.leases | grep $JBOG1_K2_MAC | awk '{print $3}')"


echo "JBOG0 K2 IP : $JBOG0_K2_IP"
echo "JBOG1 K2 IP : $JBOG1_K2_IP"

./push_CarbonNDK-primary_keg.sh $HN_K2_IP

scp $SMC_ima root@$HN_K2_IP:/root
scp pepinillo.dropbear root@$HN_K2_IP:/root

# copy to JBOG0 K2
(
/usr/bin/expect <<EOD
set timeout 30
spawn $SSH -t root@$HN_K2_IP "scp -i pepinillo.dropbear $SMC_ima root@$JBOG0_K2_IP:/root"
expect "Do you want to continue connecting"
send "y\r"
expect eof
EOD
)

# copy to JBOG1 K2
(
/usr/bin/expect <<EOD
set timeout 30
spawn $SSH -t root@$HN_K2_IP "scp -i pepinillo.dropbear $SMC_ima root@$JBOG1_K2_IP:/root"
expect "Do you want to continue connecting"
send "y\r"
expect eof
EOD
)

fi
