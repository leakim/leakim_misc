
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

# exit on return 0
source exit_on0.gdb

# start on call to gdb
run

