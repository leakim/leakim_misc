#!/bin/bash
# input
INTERFACE=$1
CHANNEL=$2

if [ "x$INTERFACE" == "x" ]; then
	INTERFACE=wlan0
fi

if [ "x$CHANNEL" == "x" ]; then
	CHANNEL=6
fi

echo "$INTERFACE: CHANNEL: $CHANNEL"

sudo rm -i /tmp/air.pcap
sudo ifconfig $INTERFACE down
sudo iwconfig $INTERFACE mode monitor
sudo iwconfig $INTERFACE channel $CHANNEL
sudo ifconfig $INTERFACE up
sudo tshark -i $INTERFACE -w /tmp/air.pcap
sudo chown miwi.miwi /tmp/air.pcap 
wireshark /tmp/air.pcap 
