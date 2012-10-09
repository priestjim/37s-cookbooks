#!/bin/sh

NAME=$1
CPU=$2
MEM=$3
IP=$4
VOLUME=`echo -n ${NAME} | sed "s/\-/_/g"`

echo "Generating VM:"
echo " - Name:     ${NAME}"
echo " - CPUs:     ${CPU}"
echo " - RAM:      ${MEM}"
echo " - IP:       ${IP}"

PATH=/usr/bin:/sbin:${PATH}

lvcreate -n kvm_${VOLUME} -L 18G VolGroupKVM
vmbuilder kvm ubuntu --suite=intrepid --flavour=virtual --arch=amd64 --hostname=${NAME} --mem=${MEM} --cpus=${CPU} \
    --mirror=http://apt/archive-ubuntu/ubuntu --dest=/u/kvm/images/${NAME} --tmp=/u/kvm/tmp --rootsize=16384 --swapsize=1024 \
    --bridge=br0 --ip=${IP} --mask=255.255.252.0 --net=192.168.0.0 --bcast=192.168.3.255 --gw=192.168.1.1 --dns=192.168.2.63 \
    --addpkg=openssh-server --addpkg=acpid --addpkg=sysstat --addpkg=emacs22-nox --addpkg=vim --addpkg=git-core \
    --addpkg=mysql-client --addpkg=libmysqlclient15-dev --addpkg=build-essential --addpkg=syslog-ng --addpkg=ntp \
    --addpkg=curl --addpkg=wget --lang=en_US.UTF-8 \
    --templates=/usr/local/share/kvm/templates \
    --copy=/usr/local/share/kvm/files/manifest.txt \
    --execscript=/usr/local/share/kvm/scripts/postinstall.sh \
    --libvirt=qemu:///system --verbose --debug

echo "Converting qcow2 image to LVM..."
kvm-img convert /u/kvm/images/${NAME}/disk0.qcow2 -O raw /u/kvm/images/${NAME}/disk0.raw
dd if=/u/kvm/images/${NAME}/disk0.raw of=/dev/mapper/VolGroupKVM-kvm_${VOLUME} bs=1M

echo "Cleaning up temporary files/directories..."
rm -rvf /u/kvm/images/${NAME}
