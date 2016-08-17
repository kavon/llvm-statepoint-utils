all: a.out

a.out: fib.o driver.o ../dist/llvm-statepoint-tablegen.a
	clang $^

fib.o:
	llc fib.ll
	gsed "s/__LLVM_StackMaps:/	.globl __LLVM_StackMaps\n__LLVM_StackMaps:/" fib.s > fib_globl.s
	clang -c fib_globl.s -o fib.o

driver.o:
	clang -c driver.c -o driver.o

clean:
	rm -f fib.s fib_globl.s fib.o driver.o a.out
