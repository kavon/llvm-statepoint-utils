#ifndef __LLVM_STATEPOINT_UTILS_HASH_TABLE__
#define __LLVM_STATEPOINT_UTILS_HASH_TABLE__

#include <stdint.h>
#include <stddef.h>
#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include "api.h"

/** Functions **/

statepoint_table_t* new_table(float loadFactor, uint64_t expectedElms);

void insert_key(statepoint_table_t* table, uint64_t key, frame_info_t* value);

/* lookup_return_address is declared in api.h */


#endif /* __LLVM_STATEPOINT_UTILS_HASH_TABLE__ */
