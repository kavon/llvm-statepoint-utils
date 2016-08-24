
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

// #define PRINT_STUFF

bool tableBuilt = false;
statepoint_table_t* table;
uint32_t* auxHeap;

uint32_t* relocate_uint32star(uint32_t** slot, uint32_t* heapPtr) {
    uint32_t val = **slot; // read val
    *heapPtr = val;  // write val
    *slot = heapPtr;    // update slot in stack frame
    return heapPtr + 1; // bump heap ptr
}


void doGC(uint8_t* stackPtr) {
    void* stackmap = (void*)&_LLVM_StackMaps;
    
    if(!tableBuilt) {
        printf("stackPtr = 0x%" PRIX64 "\n", (uint64_t)stackPtr);
        
        // setup aux heap
        printf("aux heap size = %llu bytes\n", heapSizeB);
        auxHeap = (uint32_t*) malloc(heapSizeB);
        memset(auxHeap, 0x7F, heapSizeB); 
        
        printf("printing the table...\n");
        table = generate_table(stackmap, 0.5);
        print_table(stdout, table, true);
        printf("\n\n");
        assert(lookup_return_address(table, 0) == NULL);
        // destroy_table(table);
        tableBuilt = true;
    }
    
    
    
    uint64_t retAddr = *((uint64_t*)stackPtr);
    stackPtr += sizeof(void*); // step into frame
    frame_info_t* frame = lookup_return_address(table, retAddr);
    
    // we'll be moving live stuff to the current aux heap
    uint32_t* newBase = auxHeap;
    uint32_t* newHeapPtr = auxHeap;
    
#ifdef PRINT_STUFF
    printf("\n\n--- starting to scan the stack for gc ---\n");
    printf("frame return address: 0x%" PRIX64 "\n", retAddr);
#endif
    
    while(frame != NULL) {
        
        uint16_t i;
        for(i = 0; i < frame->numSlots; i++) {
            pointer_slot_t ptrSlot = frame->slots[i];
            if(ptrSlot.kind >= 0) {
                // our example does not use derived pointers
                assert(false && "unexpected derived pointer\n");
            }
            
            uint32_t** ptr = (uint32_t**)(stackPtr + ptrSlot.offset);
            newHeapPtr = relocate_uint32star(ptr, newHeapPtr);
        }
        
        // printf("\trelocated %" PRIu16 " pointer(s).\n", i);
        
        // move to next frame. seems we have to add one pointer size to
        // reach the next return address? NOTE
        stackPtr = stackPtr + frame->frameSize;
        
        // grab return address of the frame
        retAddr = *((uint64_t*)stackPtr);
        stackPtr += sizeof(void*); // step into frame
        frame = lookup_return_address(table, retAddr);
        
#ifdef PRINT_STUFF
        printf("frame return address: 0x%" PRIX64 "\n", retAddr);
#endif
    }
    
#ifdef PRINT_STUFF
    printf("Reached the end of the stack.\n\n");
#endif
    
    // swap spaces
    auxHeap = heapBase;
    heapBase = newBase;
    heapPtr = newHeapPtr;
    
    // overwrite old space with 1's to 
    // cause weird results if something's wrong.
    memset(auxHeap, 0x7F, heapSizeB); 
}
