
#include "include/table.h"

frame_info_t* lookup_return_address(statepoint_table_t *table, uint64_t retAddr) {
    // NOTE using modulo may introduce a little bias in the table.
    uint64_t idx = hashFn(retAddr) % (table->tableSize);
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
