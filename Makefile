
CC := clang
OPT := -O3
FLAGS := -Wall -Werror -pedantic -ansi -std=c99 $(OPT)

SRC_ROOT := src
C_SRCS := $(shell find $(SRC_ROOT) -name '*.c')

BUILD_ROOT := build
C_DEPS := $(C_SRCS:$(SRC_ROOT)/%.c=$(BUILD_ROOT)/%.o)

dist/llvm-statepoint-tablegen.h: dist/llvm-statepoint-tablegen.a $(SRC_ROOT)/include/table.h
	cp $(SRC_ROOT)/include/table.h $@

dist/llvm-statepoint-tablegen.a: $(C_DEPS)
	ar rvs $@ $^
	
$(BUILD_ROOT)/%.o: $(SRC_ROOT)/%.c
	$(CC) $(FLAGS) -c $^ -o $@

clean:
	rm -f build/*
	rm -f dist/*
