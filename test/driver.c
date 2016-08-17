
#include <stdio.h>
#include "../dist/llvm-statepoint-tablegen.h"

extern uint8_t _LLVM_StackMaps[];

int callCount = 0;

void enterGC() {
    void* stackmap = (void*)&_LLVM_StackMaps;
    
    if(callCount == 0) {
        printf("printing the table...\n");
        statepoint_table_t* table = generate_table(stackmap, 0.1);
        print_table(stdout, table, true);
    }
    callCount++;
}
