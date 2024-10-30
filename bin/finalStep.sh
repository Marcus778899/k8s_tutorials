#!/bin/bash
source $HOME/Documents/Kubernetes/bin/nodeList.sh

echo "after execute this script the compute will restart ,then please submit"
echo "sudo apt-get install -y kubelet kubeadm kubectl"
echo "sudo apt-mark hold kubelet kubeadm kubectl"

for node in $all
do
    nc -w 3 -z $node 22 &>/dev/null
    [ "$?" != "0" ] && echo "ssh $node failed" && continue
    ssh $node bash<<"EOF"
sudo -i
[ ! -d /etc/apt/keyrings ] && mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
reboot
EOF
    sleep 6
done