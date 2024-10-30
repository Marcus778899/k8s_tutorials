#!/bin/bash
# containerd move to /tmp/
# containerd service move to /etc/systemd/system/
# runc move to /tmp/
# CNI move to /tmp/

package=$HOME/Documents/Kubernetes/package

[ ! -f "$package/wgetList" ] && echo "File not found" && exit 1

read -p " download package ? (y/N) " ans
if [ "$ans" == "y" ];then
    [ ! -d "$package/downliad" ] && mkdir -p $package/download

    while read -r line;
    do
        n=${line##*/}
        wget $line -P $package/download
        echo "$n download ok" 
    done < "$package/wgetList"
fi
