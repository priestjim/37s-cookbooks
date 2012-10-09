#!/bin/sh
/usr/bin/spawn-fcgi -f /usr/bin/fcgiwrap -a 127.0.0.1 -p 47000 -P /var/run/fastcgi-c.pid -u www-data -g www-data