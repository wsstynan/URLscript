#!/bin/bash

LPASS_FOLDER=$(hostname)

## /!\ CHANGE NOTHING FROM THIS POINT ON /!\ ##
 
TIMESTAMP_FILE=/home/pi/Timestamp
LPASS_BIN=/usr/bin/lpass
CHROME_BIN=/usr/bin/chromium-browser
CHROME_EXE=chromium	

export DISPLAY=:0
export LPASS_AGENT_DISABLE=1
export LPASS_HOME=/home/pi/.local/share/lpass

function start_browser {
	$LPASS_BIN ls -l $LPASS_FOLDER | cut -d ' ' -f1,2 | grep -v "v " | sort | tail -n1 > $TIMESTAMP_FILE
	pkill $CHROME_EXE
	$LPASS_BIN ls $LPASS_FOLDER | grep $LPASS_FOLDER | tail -n +2 | cut -d "]" -f1 | cut -d ' ' -f3 | xargs $LPASS_BIN show --url | xargs $CHROME_BIN --kiosk --disable-infobars > /dev/null 2>&1 &
}

$LPASS_BIN sync

# LASTPASS FOLDER UPDATES
OLD_TIMESTAMP=$(head -n1 $TIMESTAMP_FILE)
NEW_TIMESTAMP=$($LPASS_BIN ls -l $LPASS_FOLDER | cut -d ' ' -f1,2 | grep -v "v " | sort |tail -n1)
if [ "$OLD_TIMESTAMP" != "$NEW_TIMESTAMP" ]; then
	echo "LastPass vault updated, relaunching..."
	start_browser
else
	echo "No change to the vault, skipping..."
fi

# CRASHED CHROME
BROWSER_RUNNING=$(ps aux | grep chromium | grep -v grep)
if [ -z "$BROWSER_RUNNING" ]; then
	echo "Browser seems to be dead, relaunching..."
	start_browser
else
	echo "Browser running, skipping..."
fi
