

# http://www.gson.org/egypt/egypt.html
#
# objcopy --rename-section .text=.data file.o
CFLAGS=-g -Wall -fdump-rtl-expand
LDFLAGS=-g

all: test run

clean:
	rm *.o test

test: test.o

run:
	./test
	egypt foo.c.00.rtl | dot -Grotate=90 -Gsize=11,8.5 -Tps -o callgraph.ps
	egypt test.c.144r.expand | dotty -

