PLAT    := arm
CC := tcc.exe

all: test check

test: test.c
	@$(CC) $(INCLUDE) -o $@ $< 

check: 
	armsd.exe -Exec -O test_result.txt test
	cat test_result.txt

