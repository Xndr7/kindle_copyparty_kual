#!/bin/sh

TMP_DOWNLOAD="/tmp/kindle__copyparty_kual.zip"
FOLDER_EXTENSIONS="/mnt/us/extensions"

press_any_key()
{
	echo "Press any key to continue"
	while [ true ] ; do
		read -t 3 -n 1
		if [ $? = 0 ] ; then
			exit
		fi
	done
}

DOWNLOAD_URL="$(curl -s https://api.github.com/repos/Xndr7/kindle_copyparty_kual/releases/latest \
  | grep browser_download_url \
  | grep kindle_copyparty_kual.zip \
  | grep -v .zip.sig \
  | head -1 \
  | cut -d '"' -f 4)"

echo "Downloading Alpine Kindle KUAL Launcher from $DOWNLOAD_URL"
if curl -L $DOWNLOAD_URL --output $TMP_DOWNLOAD ; then
	# success
	echo "Deleting current install of Alpine Kindle KUAL Launcher"
	rm -r "$FOLDER_EXTENSIONS/kindle_copyparty_kual"
	echo "Extracting to $FOLDER_EXTENSIONS"
	unzip -q -o $TMP_DOWNLOAD -d $FOLDER_EXTENSIONS
	rm $TMP_DOWNLOAD
	echo "Kindle Copyparty KUAL Launcher installed"
	press_any_key
else
	# failed
	echo "Failed to download Launcher from $DOWNLOAD_URL"
	press_any_key
fi;
