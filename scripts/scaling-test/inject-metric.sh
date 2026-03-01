#!/bin/bash
if [ -z "$1" ]; then echo "Usage: $0 <0-100>"; exit 1; fi
echo "$1" > /tmp/fake-cpu-metric.txt
echo "CPU metric set to $1%"
