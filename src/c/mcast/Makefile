
CFLAGS=-g -Wall
LDFLAGS=-g

all: mcast run

clean:
	rm *.o mcast

mcast: mcast.o

run:
	echo "`killall -q mcast`"
	./mcast 224.0.0.42 &
	sleep 2
	./mcast 224.0.0.42 "Hello"

