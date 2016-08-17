# on OS X, install it from macports
GNU_SED := gsed

all: a.out

a.out: ../dist/llvm-statepoint-tablegen.a fib.o driver.o
	clang $^

fib.o: fib.ll
	llc fib.ll
	$(GNU_SED) "s/__LLVM_StackMaps:/	.globl __LLVM_StackMaps\n__LLVM_StackMaps:/" fib.s > fib_globl.s
	clang -c fib_globl.s -o fib.o

driver.o: driver.c
	clang -c driver.c -o driver.o

../dist/llvm-statepoint-tablegen.a:
	cd .. && make

clean:
	rm -f fib.s fib_globl.s fib.o driver.o a.out
