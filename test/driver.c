
#include <stdio.h>
#include "../dist/llvm-statepoint-tablegen.h"
#include <assert.h>
#include <stdbool.h>

extern uint8_t _LLVM_StackMaps[];
extern uint64_t heapSizeB;
extern uint32_t* heapBase;
extern uint32_t* heapPtr; // points at the first free spot in the heap


bool tableBuilt = false;
statepoint_table_t* table;

void scanStack(void* stackPtr, statepoint_table_t* table) {
    
}


void doGC(void* stackPtr) {
    void* stackmap = (void*)&_LLVM_StackMaps;
    
    if(!tableBuilt) {
        printf("stackPtr = %llu\n", (unsigned long long)stackPtr);
        printf("printing the table...\n");
        table = generate_table(stackmap, 0.5);
        print_table(stdout, table, true);
        assert(lookup_return_address(table, 0) == NULL);
        // destroy_table(table);
        tableBuilt = true;
    }
    
    
    
}
