#!/bin/bash

source $HOME/Documents/Kubernetes/bin/nodeList.sh

for node in $all; 
do

    nc -w 3 -z $node 22 &>/dev/null
    [ "$?" != "0" ] && echo "$node connect refuse" && continue
    echo "Now setting $node"
    
    ssh "$node" bash << 'EOF'
        sudo -i
        # limit parameter setup
        # Commands for displaying or setting resource limits for a shell process
        ulimit -SHn 65535
        cat << LIMIT |sudo tee -a /etc/security/limits.conf
* soft nofile 65536
* hard nofile 131072
* soft nproc 65535
* hard nproc 655350
* soft memlock unlimited
* hard memlock unlimited
LIMIT

        # Disable firewalld
        systemctl disable --now firewalld
        
        # Create k8s.conf
        cat <<CONFIG | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
CONFIG

        # Load modules
        modprobe overlay
        modprobe br_netfilter
        
        # Create sysctl.conf
        cat <<SYSCTL | tee -a /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
fs.may_detach_mounts = 1
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_watches=89100
fs.file-max=52706963
fs.nr_open=52706963
net.netfilter.nf_conntrack_max=2310720

net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl =15
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_orphans = 327680
net.ipv4.tcp_orphan_retries = 3
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.ip_conntrack_max = 65536
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_timestamps = 0
net.core.somaxconn = 16384
SYSCTL

        # Apply sysctl settings
        sysctl --system &>/dev/null

        # Comment out swap in fstab and disable swap
        sed -i '/swap/s/^/#/' /etc/fstab
        swapoff -a
        
        # Display memory info
        free
EOF

    echo "$node finish"
    echo ""
done
