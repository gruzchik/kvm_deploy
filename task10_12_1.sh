#!/bin/bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# enable config file
source ${SCRIPTPATH}/config

echo vm1=${VM1_NAME}
echo vm2=${VM2_NAME}

echo "qemu-img create -f qcow2 ${VM1_HDD} 5Gb"
qemu-img create -f qcow2 ${VM1_HDD} 5G
