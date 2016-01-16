#!/bin/bash
echo "---- Checking if containers are alive"
n=3
nn=0
toCheck=""
prefix="etherpad_"
for (( i=1; i<=$n; i++))
do
	container=$prefix$i
	status=`docker ps | grep $container`
	if [ -z "$status" ]; then
		echo "$container is down /!\\"
	else
		echo "$container is up"
		toCheck="$toCheck $container"
		nn=$(($nn + 1))
	fi
done

echo "---- Checking stats for $nn containers"
statsFile="/tmp/dockerstats"
echo 0 > /tmp/sCPU
echo 0 > /tmp/sRAM
echo 0 > /tmp/sNET
# Check stats
docker stats --no-stream $toCheck > $statsFile
# Aggro stats
cat $statsFile | grep $prefix | while read line; do
	#echo $line
	IFS=' ' read -ra arr <<< "$line"
	cpu=${arr[1]::-1}
	ram=${arr[7]::-1}
	net=${arr[8]}
	echo $cpu $ram $net

	sCPU=`cat /tmp/sCPU`
	echo $sCPU + $cpu | bc > /tmp/sCPU
	sRAM=`cat /tmp/sRAM`
	echo $sRAM + $ram | bc > /tmp/sRAM
	sNET=`cat /tmp/sNET`
	echo $sNET + $ram | bc > /tmp/sNET
done

sCPU=`cat /tmp/sCPU`
sRAM=`cat /tmp/sRAM`
sNET=`cat /tmp/sCPU`

avgCPU=`echo "$sCPU * 100 / $nn" | bc`
echo $avgCPU