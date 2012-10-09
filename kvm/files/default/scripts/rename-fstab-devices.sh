#!/bin/sh -x

cp $1/etc/fstab $1/etc/fstab.bak
cat $1/etc/fstab | sed "s/sda/vda/g" > $1/etc/fstab.new
mv $1/etc/fstab.new $1/etc/fstab
