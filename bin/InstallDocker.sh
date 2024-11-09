#!/bin/bash

source $KUBEHOME/bin/NodeList.sh

for node in $all; do
    # Check if port 22 is open on the node
    nc -w 3 -z $node 22 &>/dev/null
    if [ "$?" != 0 ]; then
        echo "Connect to $node failed"
        continue
    else
        echo "Now setting up $node"
    fi

    # SSH into the node and run commands
    ssh $node bash <<EOF
        # Update and install dependencies
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

        # Install Docker
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
        sudo usermod -aG docker \$(whoami)

        # Update Docker daemon settings
        cat <<CONFIG | sudo tee /etc/docker/daemon.json > /dev/null
{
    "registry-mirrors": [],
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "200m"
    },
    "storage-driver": "overlay2"
}
CONFIG

        # cri-dockerd
        wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.15/cri-dockerd_0.3.15.3-0.debian-bullseye_amd64.deb
        sudo dpkg -i cri-dockerd_0.3.15.3-0.debian-bullseye_amd64.deb
        rm -rf cri-dockerd_0.3.15.3-0.debian-bullseye_amd64.deb
        
        sudo systemctl deamon-reload
        sudo systemctl restart docker
        sudo systemctl enable
EOF
done
