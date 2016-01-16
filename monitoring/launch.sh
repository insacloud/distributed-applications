#!/bin/bash
id=$1
if [ -z "$INSTANCESMIN" ]; then
	INSTANCESMIN=2
fi
if [ -z "$id" ]; then
	id=$(($INSTANCESMIN + 1))
	export INSTANCESMIN=$id	# TODO FIXME
fi
echo "---- Starting new instance etherpad_$id"

# Actual work
