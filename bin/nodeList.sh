#!/bin/bash

all=$(cat /etc/hosts | grep -E "^192.168" | tr -s " " | cut -d " " -f 2)
master=$(echo "$all" | grep "^w")
worker=$(echo "$all" | grep "^W")