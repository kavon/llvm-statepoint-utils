
#include <stdio.h>
#include "../dist/llvm-statepoint-tablegen.h"

extern void* _LLVM_StackMaps;

int callCount = 0;

void enterGC() {
    
    
    if(callCount == 0) {
        // statepoint_table_t* table = generate_table(_LLVM_StackMaps, 2.0);
        // print_table(stdout, table);
        printf("stackmap at %llu\n", (unsigned long long)_LLVM_StackMaps);
        
        uint8_t* map = (uint8_t*)&_LLVM_StackMaps;
        int soFar = 0;
        for(int i = 0; i < 128; i++, soFar++) {
            if(i % 16 == 0) {
                printf("\n");
            }
            printf("%02X ", map[i]);
        }
        printf("\n");
    }
    callCount++;
}
