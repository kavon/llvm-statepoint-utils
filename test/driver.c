
#include <stdio.h>
#include "../dist/llvm-statepoint-tablegen.h"

extern uint8_t _LLVM_StackMaps[];

int callCount = 0;

void enterGC() {
    void* stackmap = (void*)&_LLVM_StackMaps;
    
    if(callCount == 0) {
        printf("printing the table...\n");
        statepoint_table_t* table = generate_table(stackmap, 0.5);
        print_table(stdout, table);
        
        // printf("stackmap at %llu\n", (unsigned long long)stackmap);
        // 
        // uint8_t* map = (uint8_t*)stackmap;
        // int soFar = 0;
        // for(int i = 0; i < 128; i++, soFar++) {
        //     if(i % 16 == 0) {
        //         printf("\n");
        //     }
        //     printf("%02X ", map[i]);
        // }
        // printf("\n");
    }
    callCount++;
}
