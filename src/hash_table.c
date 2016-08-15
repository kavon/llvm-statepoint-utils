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

__attribute((always_inline)) 
inline uint64_t computeBucketIndex(statepoint_table_t* table, uint64_t key) {
    // Using modulo may introduce a little bias in the table. 
    // If you care, use the unbiased version that's floating around the internet.
    return hashFn(key) % table->size;
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


void destroy_table(statepoint_table_t* table) {
    for(uint64_t i = 0; i < table->size; i++) {
        frame_info_t* entry = table->buckets[i].entries;
        if(entry != NULL) {
            free(entry);
        }
    }
    free(table->buckets);
    free(table);
}


inline size_t frame_size(frame_info_t* frame) {
    return sizeof(frame_info_t) + frame->numSlots * sizeof(pointer_slot_t);
}

// returns the next frame relative the current frame
inline frame_info_t* next_frame(frame_info_t* cur) {
    uint8_t* next = ((uint8_t*)cur) + frame_size(cur);
    return (frame_info_t*)next;
}

// NOTE the frame may or may not be copied when inserted into the table.
void insert_key(statepoint_table_t* table, uint64_t key, frame_info_t* value) {
    uint64_t idx = computeBucketIndex(table, key);
    table_bucket_t *bucket = table->buckets + idx;
    
    if(bucket->numEntries == 0) {
        bucket->numEntries = 1;
        bucket->sizeOfEntries = frame_size(value);
        bucket->entries = value; 
    } else {
        // a collision occured!
        size_t newSize = bucket->sizeOfEntries + frame_size(value);
        frame_info_t* newEntries = realloc(bucket->entries, newSize);
        
        if(newEntries == NULL) {
            exit(EXIT_FAILURE);
        }
        
        // copy value onto the end of the possibly resized entry array
        frame_info_t* oldEnd = (frame_info_t*)(
            ((uint8_t*)newEntries) + bucket->sizeOfEntries
        );
        
        memmove(oldEnd, value, frame_size(value));
        
        bucket->entries = newEntries;
        bucket->sizeOfEntries = newSize;
        bucket->numEntries += 1;
    }
}


frame_info_t* lookup_return_address(statepoint_table_t *table, uint64_t retAddr) {
    uint64_t idx = computeBucketIndex(table, retAddr);
    table_bucket_t bucket = table->buckets[idx];
    
    uint16_t bucketLimit = bucket.numEntries;
    frame_info_t* entries = bucket.entries;
    
    for(uint16_t i = 0; i < bucketLimit; i++) {
        if(entries->retAddr == retAddr) {
            return entries;
        }
        entries = next_frame(entries);
    }
    
    return NULL;
}
