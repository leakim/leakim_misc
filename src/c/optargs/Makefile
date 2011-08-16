

CFLAGS=-g -Wall
LDFLAGS=-g

all: test run

clean:
	rm *.o test

test: test.o

run:
	./test -d count=2 -d hex=0xdeadbeef -d negative=-1 -s name_including_spaces="m i k a e l" -s empty_string=""

