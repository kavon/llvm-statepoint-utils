
#include <stdio.h>
#include "../dist/llvm-statepoint-tablegen.h"
#include <assert.h>

extern uint8_t _LLVM_StackMaps[];

int callCount = 0;

void enterGC() {
    void* stackmap = (void*)&_LLVM_StackMaps;
    
    if(callCount == 0) {
        printf("printing the table...\n");
        statepoint_table_t* table = generate_table(stackmap, 0.5);
        print_table(stdout, table, true);
        assert(lookup_return_address(table, 0) == NULL);
        destroy_table(table);
    }
    callCount++;
}
