#!/bin/sh

if [ -f /mnt/us/extensions/kindle_copyparty/kindle_copyparty.sh ] && [ -f /mnt/us/extensions/kindle_copyparty/start_kindle_copyparty.sh ] && [ -f /etc/upstart/kindle_copyparty.conf ] && [ -f /mnt/us/extensions/kindle_copyparty/kindle_copyparty.ext3 ] ; then
    /mnt/us/extensions/kterm/bin/kterm -e "sh /mnt/us/extensions/kindle_copyparty/start_kindle_copyparty.sh" -k 1 -o U -s 7
else
	fbink -pmh -y -5 "Error: Required files missing. Deploy Alpine first!"
fi
