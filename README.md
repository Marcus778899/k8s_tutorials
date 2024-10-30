# Install K8s with kubeadm cluster

### Before you execute scripts. Please make sure that /etc/hosts and ssh-keygen set finished(id-rsa.pub must be in master authorize)

1. check execute **systemCheck.sh** to check every node status
    * Make sure that ssh is ok and chromy is activate
2. execute **systemcSetting.sh** to set every node resource, firewall and swap
    * suggest that copy the original limits.conf make you easy roll back to your orinal status
3. execute **download.sh** for wget evey k8s componets(will save in ./package/download)
4. execute **setup.sh** to install componets into system
    * after execute this script, edit /etc/containerd/config.toml => SystemdCgroup = true and "systemctl restart containerd" 
5. execute **finalStep.sh** to finish install k8s main program
    * this action will reboot all nodes.please have a little patience
6. when the node restart over.Please command in every node
    ```bash
    sudo apt-get install -y kubelet kubeadm kubectl apt-transport-https ca-certificates curl gpg
    # lock the version
    sudo apt-mark hold kubelet kubeadm kubectl
    ```
7. on the master node execute these commands(user)
    ```bash
    mkdir -p $HOME/.kube;cd $HOME/.kube
    sudo kubeadm config print init-defaults --component-configs KubeProxyConfiguration,KubeletConfiguration > $HOME/.kube/kubeadm-config.yaml
    sudo nano kubeadm-config.yaml # revise ip(advertiseAddress and podSubnet)
    sudo kubeadm init --config kubeadm-config.yaml --dry-run # check syntax
    sudo kubeadm config images pull --config kubeadm-config.yaml #pull image
    sudo kubeadm init --config kubeadm-config.yaml --upload-certs
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    sudo kubeadm token create --print-join-command >> ~/.kube/join_token.txt
    echo "token is on $HOME/.kube/join_token.txt"
    ```
8. refer $HOME/.kube/join_token.txt" to your worker node and install is Finish
9. pod network setting
    ```bash
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/custom-resources.yaml
    wget https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml
    # resive cidr with your pod-network(on master.sh)
    nano custom-resources.yaml
    kubectl apply -f custom-resources.yaml
    ```