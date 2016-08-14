
####################
# Build requirements
#
# - We specify as a minimum C99 for flexible array members.
# - Require compiler support for packed structures via __attribute__((packed))
#

CC := clang
OPT := -O3
FLAGS := -Wall -pedantic -ansi -std=c99 $(OPT)
# TODO add  -Wextra -Werror 

SRC_ROOT := src
C_SRCS := $(shell find $(SRC_ROOT) -name '*.c')

BUILD_ROOT := build
C_DEPS := $(C_SRCS:$(SRC_ROOT)/%.c=$(BUILD_ROOT)/%.o)

HEADERS := $(shell find $(SRC_ROOT) -name '*.h')

dist/llvm-statepoint-tablegen.h: dist/llvm-statepoint-tablegen.a 
	cp $(SRC_ROOT)/include/api.h $@

dist/llvm-statepoint-tablegen.a: $(C_DEPS)
	ar rvs $@ $^
	
# $< gives first prereq
$(BUILD_ROOT)/%.o: $(SRC_ROOT)/%.c $(HEADERS)
	$(CC) $(FLAGS) -c $< -o $@

clean:
	rm -f build/*
	rm -f dist/*
