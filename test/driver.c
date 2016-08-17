
#include <stdio.h>
#include "../dist/llvm-statepoint-tablegen.h"

extern void* _LLVM_StackMaps;

int callCount = 0;

void enterGC() {
    printf("stackmap at %llu\n", (unsigned long long)_LLVM_StackMaps);
    
    if(callCount == 0) {
        statepoint_table_t* table = generate_table(_LLVM_StackMaps, 2.0);
        print_table(stdout, table);
    }
    callCount++;
}
