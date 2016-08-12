
#include "include/table.h"

// imo we should bump allocate the table in one malloc'ed chunk so one
// could later integrate the generated table into final binaries. makes
// freeing easier too. should be easy to do by first doing a statistics gathering
// pass over the map 

statepoint_table_t* generate_table(void* llvm_stack_map) {
    // TODO
    return NULL;
}


void destroy_table(statepoint_table_t* table) {
    // TODO
}
