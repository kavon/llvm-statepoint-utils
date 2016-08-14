#include "include/hash_table.h"

/**
 * The hash function used to distribute keys uniformly across the table.
 * The implementation is one round of the xorshift64* algorithm.
 * Code Source: Wikipedia
 */
__attribute__((always_inline)) inline uint64_t hashFn(uint64_t x) {
    x ^= x >> 12; // a
	x ^= x << 25; // b
	x ^= x >> 27; // c
	return x * UINT64_C(2685821657736338717);
}

statepoint_table_t* new_table(float loadFactor, uint64_t expectedElms) {
    assert(loadFactor > 0 && "must be positive");
    assert(expectedElms > 0 && "must be positive");
    
    uint64_t numBuckets = (expectedElms / loadFactor) + 1;
    
    table_bucket_t* buckets = calloc(numBuckets, sizeof(table_bucket_t));
    if(buckets == NULL) {
        exit(EXIT_FAILURE);
    }
    
    statepoint_table_t* table = malloc(sizeof(statepoint_table_t));
    if(table == NULL) {
        exit(EXIT_FAILURE);
    }
    
    table->size = numBuckets;
    table->buckets = buckets;
    
    return table;
}

frame_info_t* lookup_return_address(statepoint_table_t *table, uint64_t retAddr) {
    // NOTE using modulo may introduce a little bias in the table.
    uint64_t idx = hashFn(retAddr) % (table->size);
    table_bucket_t bucket = table->buckets[idx];
    
    uint16_t bucketLimit = bucket.numEntries;
    frame_info_t* entries = bucket.entries;
    
    frame_info_t* theEntry = NULL;
    for(uint16_t i = 0; i < bucketLimit; i++) {
        if(entries[i].retAddr == retAddr) {
            theEntry = entries + i;
            break;
        }
    }
    
    return theEntry;
}
