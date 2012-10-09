#!/bin/sh -x

cp $1/boot/grub/menu.lst $1/boot/grub/menu.lst.bak

cat > $1/boot/grub/menu.lst.new <<EOF
# Enable console output via the serial port. unit 0 is /dev/ttyS0, unit 1 is /dev/ttyS1...
serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
terminal --timeout=15 serial console

EOF

cat $1/boot/grub/menu.lst.bak >> $1/boot/grub/menu.lst.new
cat $1/boot/grub/menu.lst.new | sed "s/^\(kernel.*\)/\\1 console=tty0 console=ttyS0,115200n8/g" > $1/boot/grub/menu.lst
