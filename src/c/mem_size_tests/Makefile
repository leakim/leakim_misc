

CFLAGS=-g -Wall
LDFLAGS=-g

all: func_args run

clean:
	rm *.o func_args

func_args: func_args.o

run: 
	./func_args && \
	   readelf -s func_args | head -n 3 && \
	   readelf -s func_args | grep FUNC | grep -E '( func_| main)' && \
	   readelf -t func_args | head -n6 && \
	   readelf -t func_args | grep -A 2 -E '(text|rodata|data)' | grep -v '^--'

