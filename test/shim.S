#include "gsym.h"

	.text
	.globl GSYM(enterGC)
	.extern GSYM(doGC)
GSYM(enterGC):
	mov %rsp, %rdi
	jmp GSYM(doGC)
