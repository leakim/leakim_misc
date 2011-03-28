

# objcopy --rename-section .text=.data file.o
CFLAGS=-g -Wall
LDFLAGS=-g -lduma

.PHONY: clean run

all: test run

clean:
	rm *.o test

test: test.o

run:
	gdb ./test -x run.gdb

