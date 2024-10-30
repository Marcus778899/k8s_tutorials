#!/bin/bash

source $HOME/Documents/Kubernetes/bin/nodeList.sh

for node in $all
do
    ssh $node exit &>/dev/null
    [ "$?" == "0" ] && echo "ssh $node successful"
    ssh $node docker version &>/dev/null
    [ "$?" == "0" ] && echo "$node docker setup up already" || echo "$node docker not install"
    echo "chrony setting status : $(systemctl is-active chronyd)"
    echo "containerd setting status :" $(systemctl is-active containerd.service)
done