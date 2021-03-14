.data

.balign 4
format: .asciz "%s" /* format for scanf and printf */

.balign 4
str1: .skip 12 /* the array for the first input string */

.balign
str2: .skip 12 /* the arrayv for the second input string */

.balign
strout: .skip 24 /* the array for the output string */

.balign 4
return: .word 0 /* the place for stroring lr temporarily */

.text

.global main
main:
	/* store lr to return */
	ldr r1, address_of_return
	str lr, [r1]

	/* get the first input */
	ldr r0, address_of_format
	ldr r1, address_of_str1
	bl scanf
	mov r3, #21 /* r3 stores the error code, 21 is for the first string */
	ldr r1, address_of_str1 /* scanf will mess the input variable so load the address again for judging */
	b boundary_judge /* branch to judge if the length is longer than 10 */

read2:
	/* get the second input */
	ldr r0, address_of_format
	ldr r1, address_of_str2
	bl scanf
	mov r3, #22 /* 22 is for the second string */
	ldr r1, address_of_str2 /* reload str2 address */
	b boundary_judge


boundary_judge:
	/* if the length is <= 10, the 11th byte must be empty */
	ldr r1, [r1, #10]
	cmp r1, #0
	bne error /* if the 11th byte isn't empty, branch to error and return error code */
	cmp r3, #21 
	beq read2 /* #21 means it's the first input, branch to read2, otherwise keep going to cat */

strcat1:
	ldr r0, address_of_strout /* load the address of output string */
	ldr r1, address_of_str1 /* load the address of str1 */
	mov r3, #0 /* r3 is the counter */
	b loop

strcat2:
	ldr r1, address_of_str2
	mov r3, #0
	b loop

loop:
	ldr r2, [r1, +r3] /* load the r3th char from input string */
	str r2, [r0, +r3] /* and store it to the r3th postion after r2 */
	add r3, #1 /* increment by 1 */
	cmp r2, #0 
	beq cat_judge /* if get to the end, branch to cat_judge */
	b loop
	
cat_judge:
	/* cat_judge determines if it's handing str1 or str2, and branch to different positions */ 
	ldr r2, address_of_str2
	cmp r1, r2
	beq end /* if r1 is the address of r2, the program ends */
	add r0, r3 
	sub r0, #1 /* otherwise it's handling str1. Move r0 to the end of the output string, right after the end of the copied str1 */
	b strcat2 /* continue copying str2 */
	
error:
	/* the length is > 10, return the error code */
	mov r0, r3
	ldr lr, address_of_return
	ldr lr, [lr] /* recover lr */
	bx lr
	
end:
	/* the two strings are copied and program ends */
	ldr r0, address_of_format
	ldr r1, address_of_strout
	bl printf /* print the cated string */
	
	mov r0, #0 /* recover r0 to 0 */
	ldr lr, address_of_return
	ldr lr, [lr] /* recover lr */
	bx lr

address_of_format: .word format
address_of_str1: .word str1
address_of_str2: .word str2
address_of_strout: .word strout
address_of_return: .word return
