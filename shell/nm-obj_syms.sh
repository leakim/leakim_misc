
echo '
r = {}

nm = open("nm.txt", "r")
nn = 0
for line in nm:
   kv = line.strip().split()
   if len(kv) < 2:
      continue
   size = kv[0]
   name = kv[1]
   r[name] = size

nm.close()

esum = 0
obj = open("obj.txt", "r")
en = 0
for line in obj:
   name = line.strip()
   #print "%d: %s" % (en, line)
   en = en + 1
   if r.get(name) == None:
      print "missing %s" % name
   else:
      #print "found %s" % name
      #print "del %d: %s %s" % (nn, size, name)
      esum += int(r[name])
      del r[name]

obj.close()

del r["firmware_nrx511c"]
del r["dlm1"]
del r["dlm2"]
del r["dlm3"]

ssum=0
for (name, size) in r.iteritems():
   size = int(size)
   ssum += size
   print "%-5d %s" % (size,name)

print "Sum: %d" % ssum
print "Eum: %d" % esum
print "Tot: %d" % (esum+ssum)
' > /tmp/get_size.py

find "$OBJ" -name "*.o" | while read LINE ; do 
   objdump -t "$LINE" | cut -c 18- | awk --non-decimal-data '($1==".text" || $1==".bss" || $1==".rodata"){printf("%s\n",$3)}' | grep -v "^[.]"
done > obj.txt

nm -S --size-sort obj/test_timers | awk --non-decimal-data '{printf("%d %s\n", "0x" $2, $4 )}' > nm.txt

python /tmp/get_size.py

