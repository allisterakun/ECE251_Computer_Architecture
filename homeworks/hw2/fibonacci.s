.text 
.global main

main:
	mov r1, #0
	mov r2, #1
	mov r5, #1  /* r5 as counter */

loop:
	add r0, r1, r2
	mov r1, r2
	mov r2, r0
	add r5, r5, #1
	cmp r5, #10
	bne loop

end:
	bx lr


