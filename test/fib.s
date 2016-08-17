	.section	__TEXT,__text,regular,pure_instructions
	.macosx_version_min 10, 11
	.globl	_fib
	.p2align	4, 0x90
_fib:                                   ## @fib
	.cfi_startproc
## BB#0:                                ## %entry
	pushq	%rbp
Ltmp0:
	.cfi_def_cfa_offset 16
Ltmp1:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
Ltmp2:
	.cfi_def_cfa_register %rbp
	pushq	%rbx
	subq	$24, %rsp
Ltmp3:
	.cfi_offset %rbx, -24
	movq	_gcCounter@GOTPCREL(%rip), %rbx
	cmpl	$11, (%rbx)
	jl	LBB0_2
## BB#1:                                ## %doGC
	movq	%rdi, -16(%rbp)
	callq	_enterGC
Ltmp4:
	movq	-16(%rbp), %rdi
	movl	$0, (%rbx)
LBB0_2:                                 ## %afterCheck
	incl	(%rbx)
	cmpl	$2, (%rdi)
	jl	LBB0_4
## BB#3:                                ## %r4
	movl	(%rdi), %ecx
	decl	%ecx
	movq	_heapPtr@GOTPCREL(%rip), %rbx
	movq	(%rbx), %rax
	movl	%ecx, (%rax)
	addq	$4, (%rbx)
	movq	%rdi, -16(%rbp)
	movq	%rax, %rdi
	callq	_fib
Ltmp5:
	movq	-16(%rbp), %rcx
	movl	(%rcx), %ecx
	addl	$-2, %ecx
	movq	(%rbx), %rdi
	movl	%ecx, (%rdi)
	addq	$4, (%rbx)
	movq	%rax, -24(%rbp)
	callq	_fib
Ltmp6:
	movq	-24(%rbp), %rcx
	movl	(%rcx), %ecx
	addl	(%rax), %ecx
	movq	(%rbx), %rdi
	movl	%ecx, (%rdi)
	addq	$4, (%rbx)
LBB0_4:                                 ## %r23
	movq	%rdi, %rax
	addq	$24, %rsp
	popq	%rbx
	popq	%rbp
	retq
	.cfi_endproc

	.globl	_main
	.p2align	4, 0x90
_main:                                  ## @main
	.cfi_startproc
## BB#0:
	pushq	%rbp
Ltmp7:
	.cfi_def_cfa_offset 16
Ltmp8:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
Ltmp9:
	.cfi_def_cfa_register %rbp
	movl	$12288, %edi            ## imm = 0x3000
	callq	_malloc
	movq	_heapPtr@GOTPCREL(%rip), %rcx
	movq	%rax, (%rcx)
	movl	$9, (%rax)
	addq	$4, (%rcx)
	movq	%rax, %rdi
	callq	_fib
	movl	(%rax), %edx
	leaq	L_.str(%rip), %rdi
	movl	$9, %esi
	xorl	%eax, %eax
	callq	_printf
	xorl	%eax, %eax
	popq	%rbp
	retq
	.cfi_endproc

	.comm	_heapPtr,8,3            ## @heapPtr
	.comm	_gcCounter,4,3          ## @gcCounter
	.section	__TEXT,__cstring,cstring_literals
L_.str:                                 ## @.str
	.asciz	"fib(%d) = %d\n"


	.section	__LLVM_STACKMAPS,__llvm_stackmaps
__LLVM_StackMaps:
	.byte	1
	.byte	0
	.short	0
	.long	1
	.long	0
	.long	3
	.quad	_fib
	.quad	40
	.quad	3
	.quad	2863311530
	.long	Ltmp4-_fib
	.short	0
	.short	5
	.byte	4
	.byte	8
	.short	0
	.long	0
	.byte	4
	.byte	8
	.short	0
	.long	0
	.byte	4
	.byte	8
	.short	0
	.long	0
	.byte	3
	.byte	8
	.short	7
	.long	16
	.byte	3
	.byte	8
	.short	7
	.long	16
	.short	0
	.short	0
	.p2align	3
	.quad	3149642683
	.long	Ltmp5-_fib
	.short	0
	.short	5
	.byte	4
	.byte	8
	.short	0
	.long	0
	.byte	4
	.byte	8
	.short	0
	.long	0
	.byte	4
	.byte	8
	.short	0
	.long	0
	.byte	3
	.byte	8
	.short	7
	.long	16
	.byte	3
	.byte	8
	.short	7
	.long	16
	.short	0
	.short	0
	.p2align	3
	.quad	3435973836
	.long	Ltmp6-_fib
	.short	0
	.short	5
	.byte	4
	.byte	8
	.short	0
	.long	0
	.byte	4
	.byte	8
	.short	0
	.long	0
	.byte	4
	.byte	8
	.short	0
	.long	0
	.byte	3
	.byte	8
	.short	7
	.long	8
	.byte	3
	.byte	8
	.short	7
	.long	8
	.short	0
	.short	0
	.p2align	3

.subsections_via_symbols
