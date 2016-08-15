## LLVM Statepoint Utilities

LLVM's [statepoint](http://llvm.org/docs/Statepoints.html)  infrastructure generates stack frame layout information to enable
precise garbage collection. 
However, the information is not in a suitable form for
efficient lookups by an actual garbage collector scanning the stack. 
This design is [intentional](http://llvm.org/docs/StackMaps.html#stack-map-format) because
"the runtime is expected to parse the [stack map] immediately after compiling a module and
encode the information in its own format."

The utilities herein are designed to do just that: it can generate an efficient hash table at runtime that can be used by a garbage collector to walk the stack and find all pointers. 
Generating the table at runtime works around issues with position independent code, or if that is disabled, having to do fancy linker tricks, since the table is keyed on absolute return addresses. 
The code is pure, unadulterated C99<sup>[*](#caveat)</sup> with no dependencies and a permissive license.

Note that this library was designed to work for programs whose stack map information was generated solely by ``gc.statepoint`` intrinsics, as these intrinsics generate specially formatted stack map records. If you're mixing ``patchpoint`` or regular ``stackmap`` intrinsics in the same code, you might need to modify the library in addition to marking call sites to differentiate them from statepoints.

#### how to build and use

1. Run ``make``
2. Look inside ``dist`` and you should see a library file and a header file
3. Enjoy

<a name="caveat">\*</a> *almost*... we rely on the [packed attribute](https://gcc.gnu.org/onlinedocs/gcc/Common-Type-Attributes.html#Common-Type-Attributes)
 supported by popular C compilers (*i.e.,* clang and gcc).
