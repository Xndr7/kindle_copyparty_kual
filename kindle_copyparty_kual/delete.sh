#!/bin/sh

BASE_FOLDER="/mnt/us/extensions/kindle_copyparty"

while true; do
	read -p "Are you sure you want to delete Kindle Copyparty? This will remove the files {ext3,sh,log,conf,zip}(type y or n): This will NOT remove the Copyparty related files and directories as well as the Tailscale related files and directories(if any) " yn
	case $yn in
		[Yy]* ) echo "Deleting..."; break;;
		[Nn]* ) echo "Aborted."; sh press_any_key.sh; exit;;
		* ) echo "Please answer yes or no.";;
	esac
done

rm $BASE_FOLDER/kindle_copyparty.ext3
rm $BASE_FOLDER/kindle_copyparty.sh
rm $BASE_FOLDER/start_kindle_copyparty.sh
rm $BASE_FOLDER/kindle_copyparty.conf
rm $BASE_FOLDER/kindle_copyparty.zip
while [ -f /etc/upstart/kindle_copyparty.conf ] ; do
	mntroot rw
	sleep 1
	rm /etc/upstart/kindle_copyparty.conf
	mntroot r
done
echo "Deleted Kindle Copyparty!"
sh /mnt/us/extensions/kindle_copyparty_kual/press_any_key.sh
