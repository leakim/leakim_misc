#!/bin/bash

IN="$1"
OUT="$2"

if [ "x$IN" == "x" ]; then
   IN="/tmp/air.pcap"
fi

if [ "x$OUT" == "x" ]; then
   OUT="/tmp/air_sta.pcap"
fi

if [ "x$MAC" == "x" ]; then
   MAC="00:1e:57:e7:4f:8f"
fi

FILTER="(wlan.sa == $MAC || wlan.da == $MAC || wlan.bssid == $MAC)"

tshark -R "$FILTER" -r "$IN" -w "$OUT"

