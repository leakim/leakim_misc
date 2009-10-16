

# objcopy --rename-section .text=.data file.o
CFLAGS=-g -Wall # -pg #-Werror
LDFLAGS=-g # -pg

all: test run

clean:
	rm -rf *.o test

test: test.o tun_dev.o printbuf.o

run:
	./test

