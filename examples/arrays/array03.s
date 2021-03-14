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
	str r2, [r1, +r2, LSL #2] /* *(r1 + r2*4) <- r2 */
	add r2, r2, #1		/* r2 <- r2 + 1 */
check_loop:
	cmp r2, #100		/* compare r2 and 100 */
	ble loop		/* back to loop if r2 <= 100 */
end:
	bx lr

addr_of_a: .word a
