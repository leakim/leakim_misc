#!/bin/bash

. p2p_common.sh

# globals
IF="wlan1"
MAC="unknown"

if_up $IF
if_scan $IF
wpa_supplicant_start $IF "./p2p-1.conf"
p2p_flush
sleep 0.5
p2p_find
wait_for_peer $IF
wait_for_peer "wlan2"
echo "MAC: $MAC"
wait_flags_reported
p2p_connect $IF pbc
#p2p_connect $IF "12345670" "label"
#p2p_connect $IF "12345670" "display"
#p2p_connect $IF "12345670" "keypad"
#p2p_connect $IF pin
monitor_changes $IF "$MAC" "/tmp/peer_status_$IF"
#sudo ./wpa_cli -i $IF

