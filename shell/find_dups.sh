
REF="$1"

if [ "x$REF" == "x" ];then
   echo "error: missing ref directory"
   exit 1
fi

find -type f | while read DUP_PATH ;do
   DUP_NAME="`basename $DUP_PATH`"

   find $REF -type f -name "$DUP_NAME" | while read REF_PATH ;do
      diff "$DUP_PATH" "$REF_PATH"
      if [ $? -eq 0 ]; then
         echo "$DUP_PATH" "$REF_PATH" are the same
         echo rm "$DUP_PATH"
      else
         echo "$DUP_PATH" "$REF_PATH" are not the same
      fi
   done
done

