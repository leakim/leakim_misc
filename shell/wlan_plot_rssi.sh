#!/bin/bash

#tshark -r sta_addr_only.pcap -R "(wlan.fc.type_subtype == 0x08) && (wlan.sa == 00:50:c2:6a:f2:49)"  -Tfields -eradiotap.dbm_antsignal > /tmp/rssi.txt

tshark -r "$2" -R "$1" -Tfields -eradiotap.dbm_antsignal > /tmp/rssi.txt
echo "quickplot --no-lines --point-size=5 /tmp/rssi.txt"
echo "quickplot --line-width=0 --no-points /tmp/rssi.txt"

