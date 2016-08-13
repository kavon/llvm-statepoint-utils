
#include "include/table.h"
#include "include/stackmap.h"

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
    uint64_t numFunctions = header->numFunctions;
    uint64_t numCallsites = header->numRecords;
    
    function_info_t* functions = (function_info_t*)(header + 1);
    
    // we skip over constants, which are uint64_t's
    callsite_header_t* callsite = 
        (callsite_header_t*)(
            ((uint64_t*)(functions + numFunctions)) + header->numConstants
        );
    
    uint64_t currentFun = 0;
    for(uint64_t _unused = 0; _unused < numCallsites; _unused++) {
        function_info_t* enclosingFn = functions + currentFun;
        
        generate_frame_info(callsite, enclosingFn);
        
        // TODO add the frame to a bucket etc.
        
        // setup next iteration
        
        // MAJOR TODO:
        // There's a problem with LLVM's stackmaps in that it's impossible to
        // determine which callsites belong to which functions without the additional
        // information of "number of callsites per function." (callsites are in program
        // order, as are functions).
        
        callsite = next_callsite(callsite);
    }
    
    
    
    return NULL;
}


void destroy_table(statepoint_table_t* table) {
    // TODO
}
