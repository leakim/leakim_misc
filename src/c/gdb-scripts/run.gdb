
source macro.gdb

b test.c:32
commands
   dump_ll first
   continue
end

b test.c:37
commands
   p i
   continue
end

# start on call to gdb
run
quit

