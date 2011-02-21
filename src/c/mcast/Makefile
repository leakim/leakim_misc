
CFLAGS=-g -Wall
LDFLAGS=-g

all: mcast

clean:
	rm *.o mcast

mcast:

help:
	echo "sudo ip route add 224.0.0.0/4 dev nano_dev0"

run:
	echo "`killall -q mcast`"
	./mcast 224.1.2.3 &
	sleep 2
	./mcast 224.1.2.3 "Hello"


