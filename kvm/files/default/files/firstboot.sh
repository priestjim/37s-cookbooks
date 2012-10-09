#!/bin/sh

PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin

# configure grub for serial console
cp /boot/grub/menu.lst /boot/grub/menu.lst.bak
cat > /boot/grub/menu.lst.new <<EOF
# Enable console output via the serial port. unit 0 is /dev/ttyS0, unit 1 is /dev/ttyS1...
serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
terminal --timeout=15 serial console

EOF

cat /boot/grub/menu.lst.bak >> /boot/grub/menu.lst.new
cat /boot/grub/menu.lst.new | sed "s/^\(kernel.*\)/\\1 console=tty0 console=ttyS0,115200n8/g" > /boot/grub/menu.lst

# do a first chef-client run
/usr/local/bin/chef-client 2>&1 | /usr/bin/tee /root/chef-firstboot.log


