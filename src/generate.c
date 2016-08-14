#include "include/stackmap.h"
#include "include/hash_table.h"

// imo we should bump allocate the table in one malloc'ed chunk so one
// could later integrate the generated table into final binaries. makes
// freeing easier too. should be easy to do by first doing a statistics gathering
// pass over the map 

frame_info_t* generate_frame_info(callsite_header_t* callsite, function_info_t* fn) {
    return NULL;
}

callsite_header_t* next_callsite(callsite_header_t* callsite) {
    return NULL;
}

statepoint_table_t* generate_table(void* map, float load_factor) {
    stackmap_header_t* header = (stackmap_header_t*)map;
    uint64_t numCallsites = header->numRecords;
    
    statepoint_table_t* table = new_table(load_factor, numCallsites);
    
    function_info_t* functions = (function_info_t*)(header + 1);
    
    // we skip over constants, which are uint64_t's
    callsite_header_t* callsite = 
        (callsite_header_t*)(
            ((uint64_t*)(functions + header->numFunctions)) + header->numConstants
        );
    
    
    function_info_t* currentFn = functions;
    uint32_t visited = 0;
    for(uint64_t _unused = 0; _unused < numCallsites; _unused++) {
        if(visited >= currentFn->callsiteCount) {
            currentFn++;
            visited = 0;
        }

        frame_info_t* info = generate_frame_info(callsite, currentFn);
        
        // TODO add the frame to a bucket etc.
        
        // setup next iteration
        callsite = next_callsite(callsite);
        visited++;
    }
    
    
    
    return NULL;
}


void destroy_table(statepoint_table_t* table) {
    // TODO
}
