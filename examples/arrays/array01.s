.data
.balign 4
a: .skip 400

.balign 4
b: .skip 8

.text
.global main
main:
	ldr r1, addr_of_a	/* r1 <- &a */
	mov r2, #0		/* r2 <- 0 */
loop:
	cmp r2, #100		/* Have we reached end of loop yet? */
	beq end			/* If so, leave the loop */
	add r3, r1, r2, LSL #2	/* r3 <- r1 + (4*r2) */
	str r2, [r3]		/* *r3 <- r2 */
	add r2, r2, #1		/* r2 <- r2 + 1 */
	b loop
end:
	bx lr

addr_of_a: .word a
