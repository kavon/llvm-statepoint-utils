## LLVM Statepoint Utilities

LLVM's gc.statepoint infrastructure generates stack frame layout information to enable
precise garbage collection. However, the information is not in a suitable form for
efficient lookups by an actual garbage collector. This design was intentional because
"the runtime is expected to parse the data immediately after compiling a module and
encode the information in its own format."

The utilities herein are designed to do just that: it generates an efficient hash table
that can be used by a garbage collector to walk the stack and find all pointers.
