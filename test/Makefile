CC := gcc
OPT_CC := -O3
OPT_LLC := -O3

all: a.out

a.out: ../dist/llvm-statepoint-tablegen.a fib.o driver.o shim.s
	$(CC) $(OPT_CC) $^

fib.o: fib.ll
	llc fib.ll -o fib.s
	perl -i -pe "s/__LLVM_StackMaps:/.globl __LLVM_StackMaps\n__LLVM_StackMaps:/" fib.s
	$(CC) -c fib.s -o fib.o

driver.o: driver.c
	$(CC) $(OPT_CC) -c driver.c -o driver.o

../dist/llvm-statepoint-tablegen.a:
	cd .. && make

clean:
	rm -f fib.s fib.o driver.o a.out
