
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

void relocate_uint32star(uint32_t** slot) {
    // TODO
}


void doGC(uint8_t* stackPtr) {
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
    
    
    
    // TODO make a new heap to relocate stuff to
    
    uint64_t retAddr = *((uint64_t*)stackPtr);
    frame_info_t* frame = lookup_return_address(table, retAddr);
    
    printf("\n--- starting to scan the stack for gc ---\n");
    
    while(frame != NULL) {
        printf("found a frame, relocating its ptrs\n");
        for(uint16_t i = 0; i < frame->numSlots; i++) {
            pointer_slot_t ptrSlot = frame->slots[i];
            if(ptrSlot.kind >= 0) {
                assert(false && "unexpected derived pointer\n");
            }
            uint32_t** ptr = (uint32_t**)(stackPtr + ptrSlot.offset);
            relocate_uint32star(ptr);
        }
        
        // move to next frame
        stackPtr = stackPtr + frame->frameSize;
        retAddr = *((uint64_t*)stackPtr);
        frame = lookup_return_address(table, retAddr);
    }
    
    // TODO free the old heap and make new heap the current heap.
}
