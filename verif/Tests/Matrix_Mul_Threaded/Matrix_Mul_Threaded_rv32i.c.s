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
	lw	a4,-28(s0)
	mv	a5,a4
	slli	a5,a5,1
	add	a5,a5,a4
	slli	a5,a5,2
	mv	a4,a5
	lw	a5,-40(s0)
	add	a4,a5,a4
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
	lw	a4,-24(s0)
	li	a5,2
	ble	a4,a5,.L4
	lw	a4,-44(s0)
	mv	a5,a4
	slli	a5,a5,1
	add	a4,a5,a4
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
	li	a5,2
	ble	a4,a5,.L5
	nop
	mv	a0,a5
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	Thread, .-Thread
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-112
	sw	ra,108(sp)
	sw	s0,104(sp)
	addi	s0,sp,112
	li	a5,12582912
	addi	a5,a5,4
	lw	a5,0(a5)
	sw	a5,-20(s0)
	li	a5,1
	sw	a5,-56(s0)
	li	a5,2
	sw	a5,-52(s0)
	li	a5,3
	sw	a5,-48(s0)
	li	a5,5
	sw	a5,-44(s0)
	li	a5,6
	sw	a5,-40(s0)
	li	a5,7
	sw	a5,-36(s0)
	li	a5,9
	sw	a5,-32(s0)
	li	a5,10
	sw	a5,-28(s0)
	li	a5,11
	sw	a5,-24(s0)
	li	a5,16
	sw	a5,-92(s0)
	li	a5,15
	sw	a5,-88(s0)
	li	a5,14
	sw	a5,-84(s0)
	li	a5,12
	sw	a5,-80(s0)
	li	a5,11
	sw	a5,-76(s0)
	li	a5,10
	sw	a5,-72(s0)
	li	a5,8
	sw	a5,-68(s0)
	li	a5,7
	sw	a5,-64(s0)
	li	a5,6
	sw	a5,-60(s0)
	lw	a4,-20(s0)
	li	a5,2
	beq	a4,a5,.L7
	lw	a4,-20(s0)
	li	a5,2
	bgt	a4,a5,.L8
	lw	a5,-20(s0)
	beq	a5,zero,.L9
	lw	a4,-20(s0)
	li	a5,1
	beq	a4,a5,.L10
	j	.L8
.L9:
	lw	a5,-56(s0)
	sw	a5,-104(s0)
	lw	a5,-52(s0)
	sw	a5,-100(s0)
	lw	a5,-48(s0)
	sw	a5,-96(s0)
	addi	a4,s0,-92
	addi	a5,s0,-104
	li	a2,0
	mv	a1,a4
	mv	a0,a5
	call	Thread
	j	.L8
.L10:
	lw	a5,-44(s0)
	sw	a5,-104(s0)
	lw	a5,-40(s0)
	sw	a5,-100(s0)
	lw	a5,-36(s0)
	sw	a5,-96(s0)
	addi	a4,s0,-92
	addi	a5,s0,-104
	li	a2,1
	mv	a1,a4
	mv	a0,a5
	call	Thread
	j	.L8
.L7:
	lw	a5,-32(s0)
	sw	a5,-104(s0)
	lw	a5,-28(s0)
	sw	a5,-100(s0)
	lw	a5,-24(s0)
	sw	a5,-96(s0)
	addi	a4,s0,-92
	addi	a5,s0,-104
	li	a2,2
	mv	a1,a4
	mv	a0,a5
	call	Thread
	nop
.L8:
	nop
	mv	a0,a5
	lw	ra,108(sp)
	lw	s0,104(sp)
	addi	sp,sp,112
	jr	ra
	.size	main, .-main
	.ident	"GCC: (GNU) 10.2.0"
