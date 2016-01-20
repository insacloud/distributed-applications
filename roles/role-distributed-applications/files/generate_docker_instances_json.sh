#!/bin/bash
echo "da_docker_instances:"
for i in $(eval echo {0..$1})
do
  PORT=$((9000 + $i))
  echo "  - name: etherpad_$i"
  echo "    ports: \"$PORT:9001\""
  echo "    address: localhost:$PORT"
done