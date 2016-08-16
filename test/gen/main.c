
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

// for PRIu and PRId
#define __STDC_FORMAT_MACROS 1
#include <inttypes.h>

int32_t *heapPtr;

__attribute__((always_inline)) inline int32_t* allocInt(int32_t val) {
    int32_t* allocation = heapPtr;
    *allocation = val;
    heapPtr++;
    return allocation;
}

__attribute__((always_inline)) inline int32_t readInt(int32_t* val) {
    return *val;
}

int32_t* fib(int32_t* boxedVal) {
    if(readInt(boxedVal) <= 1) {
        return boxedVal;
    }
    
    int32_t* minusOne = allocInt(readInt(boxedVal) - 1);
    int32_t* fib_minusOne = fib(minusOne); // live at callsite = { boxedVal }
    
    int32_t* minusTwo = allocInt(readInt(boxedVal) - 2);
    int32_t* fib_minusTwo = fib(minusTwo); // live at callsite = { fib_minusOne }
    
    int32_t* res = allocInt(readInt(fib_minusOne) + readInt(fib_minusTwo));
    
    return res;
}

int main() {
    const int32_t TOTAL_DEPTH = 10;
    const int32_t SIZE = (1 << (TOTAL_DEPTH)) * 3;
    heapPtr = malloc(sizeof(int32_t) * SIZE);
    
    int32_t input = TOTAL_DEPTH - 1;
    
    int32_t res = readInt(fib(allocInt(input))); // live at callsite = { }
    
    printf("fib(%" PRId32 ") = %" PRId32 "\n", input, res);
    return 0;
}
