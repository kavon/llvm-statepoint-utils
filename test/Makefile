CC := cc
OPT_CC := -O3 -fPIC
OPT_LLC := -O3 -relocation-model=pic

all: statepoints a.out

a.out: fib.o driver.o shim.S ../dist/llvm-statepoint-tablegen.a
	$(CC) $(OPT_CC) $^

fib.o: fib.ll
	llc $(OPT_LLC) fib.ll -o fib.s
	perl -i -pe "s/__LLVM_StackMaps:/.globl __LLVM_StackMaps\n__LLVM_StackMaps:/" fib.s
	$(CC) $(OPT_CC) -c fib.s -o fib.o

driver.o: driver.c
	$(CC) $(OPT_CC) -c driver.c -o driver.o

statepoints:
	cd .. && make

clean:
	rm -f fib.s fib.o driver.o a.out
