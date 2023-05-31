echo "checking the k2 connection, please wait 5 mins."

for (( i = 1; i <= 300; i++ ))
do
	ping -c 1 10.0.0.1 > /dev/null
	stat=$?
	if [ $stat == 0 ]; then
		sleep 1
		echo -n "."
	else
		echo ""
		echo "k2 ip disconnected"
		echo "re-ifconfig ens7f2 10.0.0.2"
		echo "checking the k2 connection, please wait 5 mins."
		ifconfig ens7f2 10.0.0.2
		i=0
	fi
done

echo -e "\nk2 ip connected"

#ping -c 180 10.0.0.1 > /dev/null
#stat=$?
#    if [ $stat == 0 ]; then
#        echo "k2 ip connected"
#    else
#        echo "k2 ip disconnected"
#    fi
