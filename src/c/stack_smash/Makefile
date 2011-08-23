

CFLAGS=-g -Wall
LDFLAGS=-g
CC=gcc-4.5
CFLAGS += -fstack-protector-all

all: test help run

help:
	echo "please issue 'ulimit -c 09999999'"

clean:
	rm *.o test gdb.cmd core

test: test.o

run:
	echo "run `perl -e 'print "X"x2048'`" > gdb.cmd
	#./test `perl -e 'print "X"x2048'`
	gdb ./test -x ./gdb.cmd 

