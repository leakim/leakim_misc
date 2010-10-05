

CFLAGS=-g -Wall
LDFLAGS=-g

all: func_args run func_args_c_asm

clean:
	rm *.o func_args *.lst

func_args: func_args.o

func_args_c_asm:
	gcc -c -g -Wa,-a,-ad func_args.c > func_args.lst

run: 
	./func_args && \
	   readelf -s func_args | head -n 3 && \
	   readelf -s func_args | grep FUNC | grep -E '( func_| main)' && \
	   readelf -t func_args | head -n6 && \
	   readelf -t func_args | grep -A 2 -E '(text|rodata|data)' | grep -v '^--'

