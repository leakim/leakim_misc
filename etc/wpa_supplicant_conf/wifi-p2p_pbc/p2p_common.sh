#!/bin/bash

# globals
IF="wlan1"
MAC="unknown"

function exit_on_error() {
   if [ "`cat /tmp/wpa_cli_$IF | grep FAIL | wc -l`" == "1" ]; then
      cat /tmp/wpa_cli_$IF
      rm /tmp/wpa_cli_$IF
      exit 123
   fi
}

function get_freq() {
   IF="$1"
   sudo ./wpa_cli -i $IF p2p_peer $MAC > /tmp/wpa_cli_$IF
   exit_on_error
   FREQ=`cat /tmp/wpa_cli_$IF | grep listen_freq | sed 's/listen_freq=//g'`
   echo "FREQ: $FREQ"
}

function monitor_changes() {
   IF=$1
   FILE=$3
   PSTATE=1
   STATE=2
   echo "monitor changes on $IF:$MAC"
   rm $FILE*
   while sleep 1 ; do
      sudo ./wpa_cli -i $IF p2p_peer $MAC | grep -v age= > $FILE$STATE
      if [ -e $FILE$PSTATE ]; then
         diff $FILE$PSTATE $FILE$STATE | grep -v "^---"
      else
         cat $FILE$STATE
      fi
      PSTATE=$STATE
      STATE="`echo 1+$STATE | bc`"
   done
}

function if_down() {
   IF=$1
   echo "$IF down"
   sudo ifconfig $IF down
   sleep 1
}

function if_up() {
   IF=$1
   echo "$IF up"
   sudo ifconfig $IF up
   sleep 1
}

function if_scan() {
   IF=$1
   DONE=""
   while [ "x$DONE" == "x" ]; do
      sleep 1
      C="`sudo iwlist $IF scan | grep 'Scan completed' | wc -l`"
      if [ "$C" == "1" ]; then
         DONE="1"
      fi
   done
   echo "$IF scan complete"
}

function wpa_supplicant_stop() {
   IF="$1"
   IF_CFG="$2"
   sudo killall wpa_supplicant
   sleep 1
   sudo killall -9  wpa_supplicant
}

function wpa_supplicant_start() {
   IF="$1"
   IF_CFG="$2"
   echo "starting supplicant on $IF"
   sudo ./wpa_supplicant -Dnl80211 -i "$IF" -c "$IF_CFG" -B
   sleep 1
}

function wait_for_peer() {
   IF="$1"
   echo "wait for p2p peer on $IF"
   DONE=""
   while [ "x$DONE" == "x" ]; do
      sleep 1
      sudo ./wpa_cli -i $IF p2p_peers > /tmp/wpa_cli_$IF
      X="`cat /tmp/wpa_cli_$IF | wc -l `"
      if [ "x$X" == "x1" ]; then
         DONE="x"
      fi
   done
   MAC="`cat /tmp/wpa_cli_$IF`"
}

function wait_flags_reported() {
   echo "wait for flags=[REPORTED]"
   echo "sudo ./wpa_cli -i $IF p2p_peer $MAC > /tmp/wpa_cli_$IF"
   DONE=""
   while [ "x$DONE" == "x" ]; do
      sleep 1
      sudo ./wpa_cli -i $IF p2p_peer $MAC > /tmp/wpa_cli_$IF
      exit_on_error
      X="`cat /tmp/wpa_cli_$IF | grep '^flags=' | grep REPORTED | wc -l `"
      if [ "x$X" == "x1" ]; then
         DONE="x"
      else
         cat /tmp/wpa_cli_$IF | grep '^flags='
      fi
   done
}

function p2p_find() {
   echo "p2p_find"
   sudo ./wpa_cli -i $IF p2p_find > /tmp/wpa_cli_$IF
   exit_on_error
}

function p2p_flush() {
   echo "p2p_flush"
   sudo ./wpa_cli -i $IF p2p_flush > /tmp/wpa_cli_$IF
   exit_on_error
}

function p2p_connect() {
   IF=$1
   shift
   echo "p2p_connect $MAC $@"
   sudo ./wpa_cli -i $IF p2p_peer $MAC | tee /tmp/CONNECT_BEFORE_FAIL_$IF
   exit_on_error
   sudo ./wpa_cli -i $IF p2p_connect $MAC $@ > /tmp/wpa_cli_$IF
   if [ "`cat /tmp/wpa_cli_$IF | grep FAIL | wc -l`" == "1" ]; then
      sudo ./wpa_cli -i $IF status
      sudo ./wpa_cli -i $IF p2p_peer $MAC | tee /tmp/CONNECT_FAIL_$IF
      cat /tmp/wpa_cli_$IF
      rm /tmp/wpa_cli_$IF
      exit 123
   else
      sudo mv /tmp/CONNECT_BEFORE_FAIL_$IF /tmp/CONNECT_BEFORE_SUCCESS_$IF
      sudo ./wpa_cli -i $IF p2p_peer $MAC > /tmp/CONNECT_SUCCESS_$IF
   fi
}


