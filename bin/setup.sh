#!/bin/bash

path="$HOME/Documents/Kubernetes"
source $path/bin/nodeList.sh

for node in $all
do
    scp -r "$path/package/download" $node:/tmp &>/dev/null
    echo "scp $node done"
    ssh $node bash <<'EOF'
sudo -i 
install -m 755 /tmp/download/runc.amd64 /usr/local/sbin/runc
tar Cxzvf /usr/local /tmp/download/containerd-1.6.16-linux-amd64.tar.gz
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin /tmp/download/cni-plugins-linux-amd64-v1.2.0.tgz
mv /tmp/download/containerd.service /etc/systemd/system/
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml &>/dev/null
systemctl daemon-reload
systemctl enable --now containerd
EOF
    echo "$node Done"
done