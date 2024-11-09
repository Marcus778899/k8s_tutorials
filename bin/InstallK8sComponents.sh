#!/bin/bash

source $KUBEHOME/bin/NodeList.sh

for node in $all
do
    nc -w 3 -z $node 22 &>/dev/null
    [ "$?" != "0" ] && echo "connect $node failed" && continue

    ssh $node bash <<EOF
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        
        echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
        
        sudo apt-get update
        sudo apt-get install -y kubelet kubeadm kubectl
        sudo apt-mark hold kubelet kubeadm kubectl
EOF
done