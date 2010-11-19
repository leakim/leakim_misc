#!/bin/bash
#
# script using tshark to filter out packets from a single STA and a single AP from a large wlan.pcap file
#
# example
#
# ./filter.sh 00:13:ce:e2:74:62 00:24:01:39:e3:69 air.pcap ap_sta_only.pcap
#

STA_MAC="$1"
AP_MAC="$2"
INFILE="$3"
OUTFILE="$4" # optional

if [ "x$STA_MAC" == "x" ]; then
   echo "please specify a STA mac address"
   exit 1
fi

if [ "x$AP_MAC" == "x" ]; then
   echo "please specify a AP mac address"
   exit 1
fi

if [ "x$INFILE" == "x" ]; then
   echo "please specify an pcap input file"
   exit 1
fi

STA_AP_ALL_FILE="/tmp/sta_ap_all.pcap"
STA_AP_LESS_PROBES_FILE="/tmp/sta_ap_only_probe_reply_to_sta.pcap"
STA_AP_ONLY_FILE="/tmp/sta_ap_only.pcap"

FILTER_STA_AP="`echo 'wlan.addr==STA || wlan.ta==STA || wlan.ra==STA || wlan.addr==AP || wlan.ta==AP || wlan.ra==AP || wlan.bssid==AP' | sed s/STA/$STA_MAC/g | sed s/AP/$AP_MAC/g`"
FILTER_LESS_PROBES="`echo '!((wlan.fc.type_subtype == 0x05) && !(wlan.da == STA))' | sed s/STA/$STA_MAC/g | sed s/AP/$AP_MAC/g`"
FILTER_NO_PROBES_FROM_OTHERS="`echo '!((wlan.fc.type_subtype == 0x05) && !(wlan.sa == AP))' | sed s/STA/$STA_MAC/g | sed s/AP/$AP_MAC/g`"

function filter_and_print()
{
   OUT_FILE="$1"
   IN_FILE="$2"
   FILTER="$3"
   tshark -R "$FILTER" -r "$IN_FILE" -w "$OUT_FILE"

   SIZE="`ls -s $OUT_FILE | awk '{print $1}'`"
   if [ $SIZE -eq 0 ];then
      # hu? try again using different method!
      SIZE="`wc -c $OUT_FILE | awk '{print $1}'`"
      if [ $SIZE -eq 0 ];then
         echo "file $OUT_FILE to small"
         exit 2
      else
         wc -c $OUT_FILE
      fi
   else
      ls -sh $OUT_FILE
   fi
}

if [ "x$OUTFILE" == "x" ]; then

   filter_and_print \
      "$STA_AP_ALL_FILE" \
      "$INFILE" \
      "$FILTER_STA_AP"

   filter_and_print \
      "$STA_AP_LESS_PROBES_FILE" \
      "$STA_AP_ALL_FILE" \
      "$FILTER_LESS_PROBES"

   filter_and_print \
      "$STA_AP_ONLY_FILE" \
      "$STA_AP_LESS_PROBES_FILE" \
      "$FILTER_NO_PROBES_FROM_OTHERS"

else
   # or all filters directly
   DFILTER=`echo "(($FILTER_STA_AP)&&($FILTER_LESS_PROBES)&&($FILTER_NO_PROBES_FROM_OTHERS))"`
   filter_and_print \
      "$OUTFILE" \
      "$INFILE" \
      "$DFILTER"
fi

