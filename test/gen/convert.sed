# convert all pointers to addrspace1

s:\(i[0-9][0-9]*\)\(\*\**\):\1 addrspace(1)\2:g

# then undo conversion on printf call

s:call i32 (i8 addrspace(1)\*, ...) @printf(i8 addrspace(1)\*:call i32 (i8*, ...) @printf(i8*:

# then undo conversion on printf declaration

s:declare i32 @printf(i8 addrspace(1)\*:declare i32 @printf(i8*:

# then add GC to functions

s:) #\([0-9]\) {:) #\1 gc "statepoint-example" {:
