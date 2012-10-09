#!/bin/sh

echo "Enabling ttyS0 console..."
sh /usr/local/share/kvm/scripts/grub-console.sh $1

echo "Renaming sda[12] to vda[12] in fstab..."
sh /usr/local/share/kvm/scripts/rename-fstab-devices.sh $1

echo "Setup private 172.28 network on eth1..."
sh /usr/local/share/kvm/scripts/add-172-net.sh $1
