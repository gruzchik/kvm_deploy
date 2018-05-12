#!/bin/bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# enable config file
source ${SCRIPTPATH}/config

echo vm1=${VM1_NAME}
echo vm2=${VM2_NAME}

#create xml external network and start net
MAC=52:54:00:`(date; cat /proc/interrupts) | md5sum | sed -r 's/^(.{6}).*$/\1/; s/([0-9a-f]{2})/\1:/g; s/:$//;'`
cat <<EOF > ${SCRIPTPATH}/networks/external.xml
<network>
    <name>${EXTERNAL_NET_NAME}</name>
    <forward mode='nat'>
      <nat>
        <port start='1024' end='65535'/>
      </nat>
    </forward>
    <ip address='${EXTERNAL_NET_HOST_IP}' netmask='${EXTERNAL_NET_MASK}'>
      <dhcp>
        <range start='${EXTERNAL_NET}.2' end='${EXTERNAL_NET}.254' />
        <host mac='${MAC}' name='${VM1_NAME}' ip='${VM1_EXTERNAL_IP}'/>
      </dhcp>
    </ip>
  </network>
EOF

virsh net-define ${SCRIPTPATH}/networks/external.xml
#virsh net-create ${EXTERNAL_NET_NAME}
virsh net-autostart ${EXTERNAL_NET_NAME}
virsh net-start ${EXTERNAL_NET_NAME}

#create xml internal network and start net
cat <<EOF > ${SCRIPTPATH}/networks/internal.xml
<network>
    <name>${INTERNAL_NET_NAME}</name>
  </network>
EOF

virsh net-define ${SCRIPTPATH}/networks/internal.xml
virsh net-autostart ${INTERNAL_NET_NAME}
virsh net-start ${INTERNAL_NET_NAME}

#create xml management network and start net
cat <<EOF > ${SCRIPTPATH}/networks/management.xml
<network>
    <name>${MANAGEMENT_NET_NAME}</name>
  </network>
EOF

virsh net-define ${SCRIPTPATH}/networks/management.xml
virsh net-autostart ${MANAGEMENT_NET_NAME}
virsh net-start ${MANAGEMENT_NET_NAME}

## create disk for vm1
#VM1_HDD_PATH=$(dirname ${VM1_HDD})
#[ ! -d ${VM1_HDD_PATH} ] && mkdir -p ${VM1_HDD_PATH}
#echo "qemu-img create -f qcow2 ${VM1_HDD} 5Gb"
#qemu-img create -f qcow2 ${VM1_HDD} 5G

# prepare disk for vm1 and vm2
VM1_HDD_PATH=$(dirname ${VM1_HDD})
[ ! -d ${VM1_HDD_PATH} ] && mkdir -p ${VM1_HDD_PATH}
VM2_HDD_PATH=$(dirname ${VM2_HDD})
[ ! -d ${VM2_HDD_PATH} ] && mkdir -p ${VM2_HDD_PATH}

if [ ! -x "$(command -v wget)" ]; then
	apt-get install -y wget
fi

if [ ! -f /var/lib/libvirt/images/xenial-server-cloudimg-amd64-disk1-template.qcow2 ]; then
	wget -O /var/lib/libvirt/images/xenial-server-cloudimg-amd64-disk1-template.qcow2 ${VM_BASE_IMAGE}
fi
cp -f /var/lib/libvirt/images/xenial-server-cloudimg-amd64-disk1-template.qcow2 ${VM1_HDD}
cp -f /var/lib/libvirt/images/xenial-server-cloudimg-amd64-disk1-template.qcow2 ${VM2_HDD}

# create iso for vm1 and vm2
mkisofs -o "${VM1_CONFIG_ISO}" -V cidata -r -J ${SCRIPTPATH}/config-drives/vm1-config
mkisofs -o "${VM2_CONFIG_ISO}" -V cidata -r -J ${SCRIPTPATH}/config-drives/vm2-config

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
