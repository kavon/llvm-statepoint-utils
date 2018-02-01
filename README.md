## LLVM Statepoint Utilities

LLVM's [statepoint](http://llvm.org/docs/Statepoints.html)  infrastructure generates stack frame layout information to enable
precise garbage collection. 
However, the information is not in a suitable form for
efficient lookups by an actual garbage collector scanning the stack. 
This design is [intentional](http://llvm.org/docs/StackMaps.html#stack-map-format) because
"the runtime is expected to parse the [stack map] immediately after compiling a module and
encode the information in its own format."

The utilities herein are designed to do just that: it can generate an efficient hash table at runtime that can be used by a garbage collector to walk the stack and find all pointers. 
Generating the table at runtime works around [issues](https://en.wikipedia.org/wiki/Address_space_layout_randomization) with position independent code, since the table is keyed on absolute return addresses.
The code is pure, unadulterated C99<sup>[*](#caveat)</sup> with no dependencies and a permissive license.

Note that this library was designed to work for programs whose stack map information was generated solely by ``gc.statepoint`` intrinsics, as these intrinsics generate specially formatted stack map records. If you're mixing ``patchpoint`` or regular ``stackmap`` intrinsics in the same code, you might need to modify the library in addition to marking call sites to differentiate them from statepoints.

The currently supported [Stackmap Format](http://llvm.org/docs/StackMaps.html#stack-map-format) is version 3, which is found in LLVM 5+.

#### how to build and use

1. Run ``make``
2. Look inside ``dist`` and you should see a library file and a header file
3. Enjoy

<a name="caveat">\*</a> *almost*... we rely on the [packed attribute](https://gcc.gnu.org/onlinedocs/gcc/Common-Type-Attributes.html#Common-Type-Attributes)
 supported by popular C compilers (*i.e.,* clang and gcc).
 
#### including these utils in your project

You can generate a single `.c` and corresponding `.h` file for inclusion in your own
build system. To do this, run `make unified`, and the output code will be placed under `build/`.

#### a fancier implementation

To avoid having to generate the hash table each time the program starts up, you could extend
this utility to instead generate a position-independent, static, callsite-offset table.
For example, to lookup information about a callsite, we would:

1.  Take the return address, and subtract from it the starting address of the `.text` section,
    to obtain the callsite offset.
    The starting address would change on each launch because of ASLR, 
    but it can be determined once during program startup and saved to a global variable.
    
2.  Use the call-site offset as the key into the statically allocated table. There are
    various ways of doing this, such as using a perfect hash function + a pointer array, 
    or generating a standard hash table that is laid out statically in the data section.
    
