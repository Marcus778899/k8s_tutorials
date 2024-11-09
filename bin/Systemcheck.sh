#!/bin/bash

source $KUBEHOME/bin/NodeList.sh

for node in $all
do
    echo "Now checking $node"

    nc -w 3 -z $node 22 &>/dev/null
    if [ "$?" == "0" ]; then
        echo "connect successful"
    else
        echo "connect failed"
        continue
    fi
    ssh $node docker version
    status=$(ssh $node sudo systemctl status cri-docker.service | grep -i 'Active:' | awk '{print $2, $3, $4}')
    echo "cri-dockerd status on $node: $status"

    [ $node == "master1" ] && ssh $node kubectl version
    ssh $node kubeadm version
    # SSH into the node and check the status of kubelet
    status=$(ssh $node sudo systemctl status kubelet | grep -i 'Active:' | awk '{print $2, $3, $4}')
    echo "Kubelet status on $node: $status"

    echo "========================================"
done
