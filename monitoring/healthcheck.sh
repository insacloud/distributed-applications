#!/bin/bash
echo "---- Checking if containers are alive"
if [ -z "$CPUTHRESHOLD" ]; then
	CPUTHRESHOLD=1000
fi
if [ -z "$RAMTHRESHOLD" ]; then
	RAMTHRESHOLD=1000
fi
if [ -z "$INSTANCESMIN" ]; then
	INSTANCESMIN=2
fi
n=$INSTANCESMIN
nn=0
toCheck=""
prefix="etherpad_"
for (( i=1; i<=$n; i++))
do
	container=$prefix$i
	status=`docker ps | grep $container`
	if [ -z "$status" ]; then
		echo "$container is down /!\\, starting new"
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
# Check stats
docker stats --no-stream $toCheck > $statsFile
# Aggro stats
cat $statsFile | grep $prefix | while read line; do
	#echo $line
	IFS=' ' read -ra arr <<< "$line"
	cpu=${arr[1]::-1}
	ram=${arr[7]::-1}

	sCPU=`cat /tmp/sCPU`
	echo $sCPU + $cpu | bc > /tmp/sCPU
	sRAM=`cat /tmp/sRAM`
	echo $sRAM + $ram | bc > /tmp/sRAM
done

sCPU=`cat /tmp/sCPU`
sRAM=`cat /tmp/sRAM`

# Yes, it's in /10 000
avgCPU=`echo "$sCPU * 100 / $nn" | bc`
avgRAM=`echo "$sRAM * 100 / $nn" | bc`

echo "Average CPU load: $avgCPU / 10000 - thr: $CPUTHRESHOLD"
echo "Average RAM load: $avgRAM / 10000 - thr: $RAMTHRESHOLD"

if [ $avgCPU -gt $CPUTHRESHOLD ] || [ $avgRAM -gt $RAMTHRESHOLD ]; then
	echo "Load too high, starting instance"
fi