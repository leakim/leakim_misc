
# To generate 'core' files you must first have issued
#
# ulimit -c unlimite
#
# to change the 'core' filename to something that is less likly to be overwritten issue
# 
# echo "%e.core.pid_%p.ts_%t" | sudo tee /proc/sys/kernel/core_pattern
#
# read 'core' file using
#
# gdb ./test core"
#

CFLAGS=-g -Wall
LDFLAGS=-g

all: test run

clean:
	rm *.o test

test: test.o

run:
	./test

