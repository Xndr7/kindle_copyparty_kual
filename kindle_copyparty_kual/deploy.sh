#!/bin/bash
mkdir -p /mnt/us/extensions/kindle_copyparty
cd /mnt/us/extensions/kindle_copyparty
echo "*** Deploying / Updating Alpine Linux ***"

BASE_FOLDER="/mnt/us/extensions/kindle_copyparty"

deploy_alpine()
{
	echo "Deploying Alpine.."
	echo "Downloading from GitHub"
	lipc-set-prop com.lab126.powerd preventScreenSaver 1

	ALPINE_URL="$(curl -s https://api.github.com/repos/Xndr7/Kindle_Copyparty/releases/latest \
	  | grep browser_download_url \
	  | grep kindle_copyparty \
	  | head -1 \
	  | cut -d '"' -f 4)"

	echo "Downloading Kindle Copyparty from $ALPINE_URL"
	if ! curl -L $ALPINE_URL --output "$BASE_FOLDER/kindle_copyparty.zip" ; then
		# failed
		echo "Failed to download from $ALPINE_URL"
		sh /mnt/us/extensions/kindle_copyparty_kual/press_any_key.sh
		lipc-set-prop com.lab126.powerd preventScreenSaver 0
		exit
	fi;

	echo "Checking Storage space"
	B_REQUIRED="$(unzip -l "$BASE_FOLDER/kindle_copyparty.zip" | tail -1 | cut -d' ' -f1)"
	KB_REQUIRED="$((B_REQUIRED/1024))"
	KB_FREE="$(df -k $BASE_FOLDER | awk '{print $4}' | tail -n -1)"
	echo "Required: $KB_REQUIRED kb"
	echo "Free: $KB_FREE kb"
	PERCENTAGE_TO_BE_USED="$(($KB_REQUIRED*100/$KB_FREE))"
	if [ "$PERCENTAGE_TO_BE_USED" -gt "99" ] ; then
		echo "Error: Not enough free storage space!"
		sh /mnt/us/extensions/kindle_copyparty_kual/press_any_key.sh
		lipc-set-prop com.lab126.powerd preventScreenSaver 0
		exit
	else
		echo "Sufficient amount of free storage space available, will use $PERCENTAGE_TO_BE_USED% of that."
	fi

	echo "Extracting to /mnt/us/extensions/kindle_copyparty"
	echo "This can take a while, please be patient..."
	sh /mnt/us/extensions/kindle_copyparty_kual/unzip_progress.sh &
	unzip -o "$BASE_FOLDER/kindle_copyparty.zip" -d "$BASE_FOLDER" 

	echo "Copying service \"kindle_copyparty\" into system"
	while [ ! -f /etc/upstart/kindle_copyparty.conf ] ; do
		mntroot rw
		sleep 1
		cp $BASE_FOLDER/kindle_copyparty.conf /etc/upstart/kindle_copyparty.conf
		mntroot r
	done

	echo "Install is done!"
	sh /mnt/us/extensions/kindle_copyparty_kual/press_any_key.sh
	lipc-set-prop com.lab126.powerd preventScreenSaver 0
	exit
}


if [ -f $BASE_FOLDER/kindle_copyparty.ext3 ] ; then
	echo "Error: alpine.ext already exists. If you want to update Alpine Linux to the latest release for Kindle, you need to delete it first. ATTENTION! This will delete all data inside Alpine!"
	echo "Press any key to go back to the menu where you have the option to delete."
	sh /mnt/us/extensions/kindle_copyparty_kual/press_any_key.sh
exit
else
	deploy_alpine
fi
