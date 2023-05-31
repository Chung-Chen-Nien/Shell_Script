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
echo "JBOG0 SMC IP : $JBOG0_IP"

for FRU_ID in 2 ;
do
        sleep 1
        JBOG0_K2_MAC="$($IPMI $JBOG0_IP fru print $FRU_ID | grep -A 1 "Mac_Port_2"|tail -n 1|awk '{print $4}')"
        #ipmitool -Uadmin -Padmin -H hn1j2 fru print $FRU_ID | grep -A 1 "Mac_Port_2"|tail -n 1|awk '{print $4}'
done

echo "JBOG0 MAC : $JBOG0_K2_MAC"
JBOG0_K2_MAC="${JBOG0_K2_MAC:6:2}:${JBOG0_K2_MAC:8:2}:${JBOG0_K2_MAC:10:2}"
#echo $JBOG0_K2_MAC

#coap -O65001,0 -Y coaps+tcp://$HN_K2_IP/api-v1/debug/fs/local/var/cordite/dhcp.leases > /dev/null 2>&1

JBOG0_K2_IP="$(coap -O65001,0 -Y coaps+tcp://$HN_K2_IP/break-glass-v1/debug/fs/local/var/cordite/dhcp.leases | grep $JBOG0_K2_MAC | awk '{print $3}')"

echo "JBOG0 K2 IP : $JBOG0_K2_IP"

#./push_CarbonNDK-primary_keg.sh $HN_K2_IP
#
#scp $SMC_ima root@$HN_K2_IP:/root
#scp pepinillo.dropbear root@$HN_K2_IP:/root
#
## copy to JBOG K2
#(
#/usr/bin/expect <<EOD
#set timeout 30
#spawn $SSH -t $HN_K2_IP "scp -i pepinillo.dropbear $SMC_ima $JBOG0_K2_IP:/root"
#expect "Do you want to continue connecting"
#send "y\r"
#expect eof
#EOD
#)

$IPMI $BMC_IP raw 0x34 0x94 2 0 1
#$IPMI $BMC_IP raw 0x34 0x94 2 1 1

UPDATE_CMD=("al_tool -s local uc -c gpio_write -p 3 -b 0 -v 1 ; \
             al_tool -s local spi -c write --spi_select 2 --write_verify --cs 0 --freq 12000000 -i $SMC_ima")


$SSH -t root@$HN_K2_IP "ssh -i pepinillo.dropbear root@$JBOG0_K2_IP '$UPDATE_CMD'" | tee -a update_smc_${BMC_IP}_j0.log

$IPMI $BMC_IP raw 0x34 0x94 2 0 0
#$IPMI $BMC_IP raw 0x34 0x94 2 1 0
#$IPMI $BMC_IP mc reset cold
echo "HN need to mc reset cold if don't have another JBOG SMC need to flash"
#echo "wait SMC ready... , 3mins"
#sleep 3m # wait SMC ready...

if grep -q "write 0x100000 bytes to 0x3f00000 completed" update_smc_${BMC_IP}_j0.log ;
then
        echo "SMC update succeeded, update_smc_${BMC_IP}_j0.log is recorded."
else
        echo "SMC update failed, update_smc_${BMC_IP}_j0.log is recorded.."
fi

fi
