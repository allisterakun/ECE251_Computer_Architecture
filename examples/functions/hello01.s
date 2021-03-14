/* hello01.s */
.data

.balign 4
greeting: .asciz "Hello world"

.balign 4
return: .word 0

.text

.global main
main:
	ldr r1, address_of_return 	/* r1 <- &return */
	str lr, [r1]			/* *r1 <- lr */

	ldr r0, address_of_greeting	/* r0 <- &greeting */

	bl puts				/* Call to puts */
					/* lr <- address of next instruction */

	ldr r1, address_of_return	/* r1 <- &return */
	ldr lr, [r1]
	bx lr

address_of_greeting: .word greeting
address_of_return:   .word return

/* External */
.global puts
