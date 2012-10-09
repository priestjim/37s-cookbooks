#!/bin/sh -x

LAST_OCTET=`grep address $1/etc/network/interfaces | awk -F. '{ print $4 }'`
PRIV_IP="172.28.5.${LAST_OCTET}"

cp $1/etc/network/interfaces $1/etc/network/interfaces.bak
cat >> $1/etc/network/interfaces <<EOF

auto eth1
iface eth1 inet static
        address $PRIV_IP
        netmask 255.255.0.0
        network 172.28.0.0
        broadcast 172.28.255.255

EOF
