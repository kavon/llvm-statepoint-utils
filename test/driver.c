
#include <stdio.h>
#include "../dist/llvm-statepoint-tablegen.h"
#include <assert.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>

extern uint8_t _LLVM_StackMaps[];
extern uint64_t heapSizeB;
extern uint32_t* heapBase;
extern uint32_t* heapPtr; // points at the first free spot in the heap


bool tableBuilt = false;
statepoint_table_t* table;
uint32_t* auxHeap;

void relocate_uint32star(uint32_t** slot, uint32_t** heapPtr) {
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
        
        // setup aux heap
        auxHeap = (uint32_t*) malloc(heapSizeB);
        memset(auxHeap, 0xFF, heapSizeB); 
    }
    
    printf("\n--- starting to scan the stack for gc ---\n");
    
    uint64_t retAddr = *((uint64_t*)stackPtr);
    frame_info_t* frame = lookup_return_address(table, retAddr);
    
    // we'll be moving live stuff to the current aux heap
    uint32_t* newBase = auxHeap;
    uint32_t* newHeapPtr = auxHeap;
    
    while(frame != NULL) {
        printf("found a frame, relocating its ptrs\n");
        for(uint16_t i = 0; i < frame->numSlots; i++) {
            pointer_slot_t ptrSlot = frame->slots[i];
            if(ptrSlot.kind >= 0) {
                // our example does not use derived pointers
                assert(false && "unexpected derived pointer\n");
            }
            uint32_t** ptr = (uint32_t**)(stackPtr + ptrSlot.offset);
            relocate_uint32star(ptr, &newHeapPtr);
        }
        
        // move to next frame
        stackPtr = stackPtr + frame->frameSize;
        retAddr = *((uint64_t*)stackPtr);
        frame = lookup_return_address(table, retAddr);
    }
    
    // swap spaces
    /* TODO only enable this once you correctly relocate everything!
    auxHeap = heapBase;
    heapBase = newBase;
    heapPtr = newHeapPtr;
    
    // overwrite old space with 1's to 
    // cause weird results if something's wrong.
    memset(auxHeap, 0xFF, heapSizeB); 
    */
}
