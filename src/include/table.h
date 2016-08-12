#ifndef __LLVM_STATEPOINT_UTILS_TABLE__
#define __LLVM_STATEPOINT_UTILS_TABLE__

#include "stdint.h"
#include "stddef.h"

/**** Types ****/

typedef struct {
    uint64_t retAddr;
    uint64_t frameSize;
    uint64_t numOffsets;
    uint64_t *offsets;
} frame_info_t;


typedef struct {
    uint16_t numEntries;
    frame_info_t* entries;
} table_bucket_t;

typedef struct {
    // hashVal AND mask = bucket in table for that entry.
    // Yes, using modulo may introduce some bias in the table, but this is fast :)
    uint64_t tableMask; 
    table_bucket_t* buckets;
} statepoint_table_t;



/**** Public Functions ****/

/**
 * An amortized O(1) return address lookup function for garbage collectors.
 *
 * table - table to lookup an entry in
 * key - the return address corresponding to the frame you would like information about
 *
 */
frame_info_t* lookup_return_address(statepoint_table_t *table, uint64_t retAddr);

/**
 * Given an LLVM generated Stack Map, will return a table suitable for
 * efficient return address lookups by a garbage collector.
 *
 */
statepoint_table_t* generate_table(void* llvm_stack_map);


/**
 * Frees the memory allocated for the table.
 */
void destroy_table(statepoint_table_t* table);




/**** Private Functions ****/

/**
 * The hash function used to distribute keys uniformly across the table.
 * The implementation is one round of the xorshift64* algorithm.
 * Code Source: Wikipedia
 */
__attribute__((always_inline)) uint64_t hashFn(uint64_t x) {
    x ^= x >> 12; // a
	x ^= x << 25; // b
	x ^= x >> 27; // c
	return x * UINT64_C(2685821657736338717);
}


#endif /* __LLVM_STATEPOINT_UTILS_TABLE__ */
