	.file	"Matrix_Mul_Threaded.c"
	.option nopic
	.attribute arch, "rv32i2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.globl	__mulsi3
	.align	2
	.globl	Thread
	.type	Thread, @function
Thread:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	sw	a2,-44(s0)
	sw	zero,-24(s0)
	j	.L2
.L5:
	sw	zero,-20(s0)
	sw	zero,-28(s0)
	j	.L3
.L4:
	lw	a5,-28(s0)
	slli	a5,a5,2
	lw	a4,-36(s0)
	add	a5,a4,a5
	lw	a3,0(a5)
	lw	a5,-28(s0)
	slli	a5,a5,4
	lw	a4,-40(s0)
	add	a4,a4,a5
	lw	a5,-24(s0)
	slli	a5,a5,2
	add	a5,a4,a5
	lw	a5,0(a5)
	mv	a1,a5
	mv	a0,a3
	call	__mulsi3
	mv	a5,a0
	mv	a4,a5
	lw	a5,-20(s0)
	add	a5,a5,a4
	sw	a5,-20(s0)
	lw	a5,-28(s0)
	addi	a5,a5,1
	sw	a5,-28(s0)
.L3:
	lw	a4,-28(s0)
	li	a5,3
	ble	a4,a5,.L4
	lw	a5,-44(s0)
	slli	a4,a5,2
	lw	a5,-24(s0)
	add	a5,a4,a5
	slli	a4,a5,2
	li	a5,4198400
	addi	a5,a5,-256
	add	a5,a4,a5
	lw	a4,-20(s0)
	sw	a4,0(a5)
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L2:
	lw	a4,-24(s0)
	li	a5,3
	ble	a4,a5,.L5
	nop
	mv	a0,a5
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	Thread, .-Thread
	.section	.rodata
	.align	2
.LC0:
	.word	1
	.word	2
	.word	3
	.word	4
	.word	5
	.word	6
	.word	7
	.word	8
	.word	9
	.word	10
	.word	11
	.word	12
	.word	13
	.word	14
	.word	15
	.word	16
	.align	2
.LC1:
	.word	13
	.word	14
	.word	15
	.word	16
	.word	9
	.word	10
	.word	11
	.word	12
	.word	5
	.word	6
	.word	7
	.word	8
	.word	1
	.word	2
	.word	3
	.word	4
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-192
	sw	ra,188(sp)
	sw	s0,184(sp)
	addi	s0,sp,192
	li	a5,12582912
	addi	a5,a5,4
	lw	a5,0(a5)
	sw	a5,-36(s0)
	lui	a5,%hi(.LC0)
	addi	a4,a5,%lo(.LC0)
	addi	a5,s0,-100
	mv	a3,a4
	li	a4,64
	mv	a2,a4
	mv	a1,a3
	mv	a0,a5
	call	memcpy
	lui	a5,%hi(.LC1)
	addi	a4,a5,%lo(.LC1)
	addi	a5,s0,-164
	mv	a3,a4
	li	a4,64
	mv	a2,a4
	mv	a1,a3
	mv	a0,a5
	call	memcpy
	lw	a4,-36(s0)
	li	a5,3
	beq	a4,a5,.L7
	lw	a4,-36(s0)
	li	a5,3
	bgt	a4,a5,.L8
	lw	a4,-36(s0)
	li	a5,2
	beq	a4,a5,.L9
	lw	a4,-36(s0)
	li	a5,2
	bgt	a4,a5,.L8
	lw	a5,-36(s0)
	beq	a5,zero,.L10
	lw	a4,-36(s0)
	li	a5,1
	beq	a4,a5,.L11
	j	.L8
.L10:
	sw	zero,-20(s0)
	j	.L12
.L13:
	lw	a5,-36(s0)
	slli	a4,a5,2
	lw	a5,-20(s0)
	add	a5,a4,a5
	slli	a5,a5,2
	addi	a4,s0,-16
	add	a5,a4,a5
	lw	a4,-84(a5)
	lw	a5,-20(s0)
	slli	a5,a5,2
	addi	a3,s0,-16
	add	a5,a3,a5
	sw	a4,-164(a5)
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L12:
	lw	a4,-20(s0)
	li	a5,3
	ble	a4,a5,.L13
	addi	a4,s0,-164
	addi	a5,s0,-180
	li	a2,0
	mv	a1,a4
	mv	a0,a5
	call	Thread
	j	.L8
.L11:
	sw	zero,-24(s0)
	j	.L14
.L15:
	lw	a5,-36(s0)
	slli	a4,a5,2
	lw	a5,-24(s0)
	add	a5,a4,a5
	slli	a5,a5,2
	addi	a4,s0,-16
	add	a5,a4,a5
	lw	a4,-84(a5)
	lw	a5,-24(s0)
	slli	a5,a5,2
	addi	a3,s0,-16
	add	a5,a3,a5
	sw	a4,-164(a5)
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L14:
	lw	a4,-24(s0)
	li	a5,3
	ble	a4,a5,.L15
	addi	a4,s0,-164
	addi	a5,s0,-180
	li	a2,1
	mv	a1,a4
	mv	a0,a5
	call	Thread
	j	.L8
.L9:
	sw	zero,-28(s0)
	j	.L16
.L17:
	lw	a5,-36(s0)
	slli	a4,a5,2
	lw	a5,-28(s0)
	add	a5,a4,a5
	slli	a5,a5,2
	addi	a4,s0,-16
	add	a5,a4,a5
	lw	a4,-84(a5)
	lw	a5,-28(s0)
	slli	a5,a5,2
	addi	a3,s0,-16
	add	a5,a3,a5
	sw	a4,-164(a5)
	lw	a5,-28(s0)
	addi	a5,a5,1
	sw	a5,-28(s0)
.L16:
	lw	a4,-28(s0)
	li	a5,3
	ble	a4,a5,.L17
	addi	a4,s0,-164
	addi	a5,s0,-180
	li	a2,2
	mv	a1,a4
	mv	a0,a5
	call	Thread
	j	.L8
.L7:
	sw	zero,-32(s0)
	j	.L18
.L19:
	lw	a5,-36(s0)
	slli	a4,a5,2
	lw	a5,-32(s0)
	add	a5,a4,a5
	slli	a5,a5,2
	addi	a4,s0,-16
	add	a5,a4,a5
	lw	a4,-84(a5)
	lw	a5,-32(s0)
	slli	a5,a5,2
	addi	a3,s0,-16
	add	a5,a3,a5
	sw	a4,-164(a5)
	lw	a5,-32(s0)
	addi	a5,a5,1
	sw	a5,-32(s0)
.L18:
	lw	a4,-32(s0)
	li	a5,3
	ble	a4,a5,.L19
	addi	a4,s0,-164
	addi	a5,s0,-180
	li	a2,3
	mv	a1,a4
	mv	a0,a5
	call	Thread
	nop
.L8:
	nop
	mv	a0,a5
	lw	ra,188(sp)
	lw	s0,184(sp)
	addi	sp,sp,192
	jr	ra
	.size	main, .-main
	.ident	"GCC: (GNU) 10.2.0"
