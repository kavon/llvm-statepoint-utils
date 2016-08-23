	.text
	.globl _enterGC
	.extern _doGC
_enterGC:
	mov %rsp, %rdi
	jmp _doGC
