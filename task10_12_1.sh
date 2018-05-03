#!/bin/bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# enable config file
source ${SCRIPTPATH}/config

echo vm1=${VM1_NAME}
echo vm2=${VM2_NAME}

# create disk for vm1
VM1_HDD_PATH=$(dirname ${VM1_HDD})
[ ! -d ${VM1_HDD_PATH} ] && mkdir -p ${VM1_HDD_PATH}
echo "qemu-img create -f qcow2 ${VM1_HDD} 5Gb"
qemu-img create -f qcow2 ${VM1_HDD} 5G

## create vm1
#virt-install \
#--connect qemu:///system \
#--name ${VM1_NAME} \
#--ram ${VM1_MB_RAM} --vcpus=${VM1_NUM_CPU} --hvm \
#--os-type=linux --os-variant=ubuntu16.04 \
#--disk path=${VM1_HDD},format=qcow2,bus=virtio,cache=none \
#--location 'http://us.archive.ubuntu.com/ubuntu/dists/xenial/main/installer-amd64/' \
#--graphics vnc,port=-1 \
#--noautoconsole --quiet --virt-type kvm --import
##--disk path=${VM1_CONFIG_ISO},device=cdrom \
##--network network=default,mac='52:54:00:07:ca:ba' \
