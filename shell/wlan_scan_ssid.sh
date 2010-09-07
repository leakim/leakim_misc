#!/bin/bash

# input
INTERFACE=wlan0
SSID=$1

if [ "x$SSID" == "x" ]; then
	echo "no ssid provided; exiting"
	exit 1
fi

echo "scanning for ssid: $SSID using $INTERFACE"

MMODE="`iwconfig $INTERFACE 2>/dev/null | grep $INTERFACE | grep Mode | grep Monitor | wc -l`"
if [ "$MMODE" == "1" ]; then
	echo "found you are in Monitor mode, switching to Managed"

	sudo ifconfig $INTERFACE down
	sudo iwconfig $INTERFACE mode managed
	sudo ifconfig $INTERFACE up
fi

sudo iwlist $INTERFACE scan

