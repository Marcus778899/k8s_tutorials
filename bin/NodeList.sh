#!/bin/bash

all=$(cat /etc/hosts | grep -E "^192.168" | tr -s " " | cut -d " " -f 2)
master=$(echo "$all" | grep "^m")
worker=$(echo "$all" | grep "^w")