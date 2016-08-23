
#include <stdio.h>
#include "../dist/llvm-statepoint-tablegen.h"
#include <assert.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>

// for PRIu and PRId
#define __STDC_FORMAT_MACROS 1
#include <inttypes.h>

extern uint8_t _LLVM_StackMaps[];
extern uint64_t heapSizeB;
extern uint32_t* heapBase;
extern uint32_t* heapPtr; // points at the first free spot in the heap


bool tableBuilt = false;
statepoint_table_t* table;
uint32_t* auxHeap;

void relocate_uint32star(uint32_t** slot, uint32_t** heapPtr) {
    uint32_t* newSlot = *heapPtr;
    *newSlot = **slot; // move val
    *slot = newSlot; // update the slot in stack frame
    *heapPtr = (*heapPtr) + 1; // increment heap ptr
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
    
    printf("\n\n--- starting to scan the stack for gc ---\n");
    
    uint64_t retAddr = *((uint64_t*)stackPtr);
    printf("frame return address: 0x%" PRIX64 "\n", retAddr);
    frame_info_t* frame = lookup_return_address(table, retAddr);
    
    // we'll be moving live stuff to the current aux heap
    uint32_t* newBase = auxHeap;
    uint32_t* newHeapPtr = auxHeap;
    
    while(frame != NULL) {
        
        printf("\t... relocating\n");
        
        for(uint16_t i = 0; i < frame->numSlots; i++) {
            pointer_slot_t ptrSlot = frame->slots[i];
            if(ptrSlot.kind >= 0) {
                // our example does not use derived pointers
                assert(false && "unexpected derived pointer\n");
            }
            uint32_t** ptr = (uint32_t**)(stackPtr + ptrSlot.offset);
            relocate_uint32star(ptr, &newHeapPtr);
        }
        
        printf("\tdone.\n");
        
        // move to next frame. seems we have to add one pointer size to
        // reach the next return address? NOTE
        stackPtr = stackPtr + frame->frameSize + sizeof(uint64_t*); 
        
        retAddr = *((uint64_t*)stackPtr);
        printf("frame return address: 0x%" PRIX64 "\n", retAddr);
        frame = lookup_return_address(table, retAddr);
    }
    
    printf("finished!\n");
    
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
