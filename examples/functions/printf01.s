/* -- printf01.s */
.data

/* First message */
.balign 4
msg1: .asciz "Hey, type a number: "

/* Second message */
.balign 4
msg2: .asciz "I read the number %d\n"

/* Format pattern for scanf */
.balign 4
scan_pattern: .asciz "%d"

/* Where scanf will store the number read */
.balign 4
number_read: .word 0

.balign 4
return: .word 0

.text

.global main
main:
	ldr r1, return_addr		/* r1 <- &return */
	str lr, [r1]			/* *r1 <- lr */

	ldr r0, msg1_addr 		/* r0 <- &mg1 */
	bl printf			/* call printf */

	ldr r0, scan_pattern_addr	/* r0 <- &scan_pattern */
	ldr r1, number_read_addr	/* r1 <- &number_read */
	bl scanf			/* call scanf */

	ldr r0, msg2_addr		/* r0 <- &msg2 */
	ldr r1, number_read_addr	/* r1 <- &number_read */
	ldr r1, [r1]			/* r1 <- *r1 */
	bl printf

	ldr r0, number_read_addr	/* r0 <- &number_read */
	ldr r0, [r0]			/* r0 <- *r0 */

	ldr lr, return_addr		/* lr <- &return */
	ldr lr, [lr]			/* lr <- *lr */
	bx lr				/* return from main using restored lr */

return_addr: 		.word return
msg1_addr:   		.word msg1
scan_pattern_addr: 	.word scan_pattern
number_read_addr:	.word number_read
msg2_addr:		.word msg2

/* External */
.global printf
.global scanf
