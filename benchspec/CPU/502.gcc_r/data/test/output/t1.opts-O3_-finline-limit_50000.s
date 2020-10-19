	.file	"t1.c"
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"hello world\n"
	.text
	.p2align 4,,15
.globl main
	.type	main, @function
main:
	pushl	%ebp
	movl	%esp, %ebp
	andl	$-16, %esp
	subl	$16, %esp
	movl	$.LC0, (%esp)
	call	printf
	xorl	%eax, %eax
	leave
	ret
	.size	main, .-main
	.ident	"GCC: 4.5.0SPEC4.5.0SPEC"
	.section	.note.GNU-stack,"",@progbits
