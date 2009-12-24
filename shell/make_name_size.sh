time sudo find -type f -size +100000 -exec ls -l {} \; | awk '{$1=""; $2=""; $3=""; $4=""; $6=""; $7=""; print $0; }' | tee /tmp/name-size.txt
awk '{$1=""; print $0}' name-size.txt  | while read LINE; do basename "$LINE" ; done | sort | uniq -c | sort -n | tee names.txt
