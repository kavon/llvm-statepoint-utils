
####################
# Build requirements
#
# - We specify as a minimum C99 for flexible array members.
# - Require compiler support for packed structures via __attribute__((packed))
#

CC := clang
OPT := -O3
#OPT := -g
FLAGS := -Wall -Wextra -Werror -Wpedantic -std=c99 $(OPT)

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
	
unified:
	# roll together the headers. api.h needs to come first so we sort the headers.
	cat $(sort $(HEADERS)) >> $(BUILD_ROOT)/statepoint.h
	# make the C file
	echo "#include \"statepoint.h\"" > $(BUILD_ROOT)/statepoint.c
	sed -E -e "s:[[:space:]]*#include[[:space:]]+\"include/.+\":// include auto-removed:g" $(C_SRCS) >> $(BUILD_ROOT)/statepoint.c
	# ensure that it compiles
	$(CC) -c $(BUILD_ROOT)/statepoint.c -o $(BUILD_ROOT)/statepoint.o

clean:
	rm -f build/*
	rm -f dist/*
