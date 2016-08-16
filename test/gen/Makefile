
INTERMEDIATES := 

all: starter.ll main

main: main.c
	clang main.c -o main

starter.ll: main.c
	clang -S -emit-llvm main.c -o main.ll
	opt -S -mem2reg main.ll -o main_clean.ll
	sed -f convert.sed main_clean.ll > starter.ll
	rm main.ll
	rm main_clean.ll

clean:
	rm -f main starter.ll
