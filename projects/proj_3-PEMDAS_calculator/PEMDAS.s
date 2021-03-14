.data

.balign 4
int_format: .asciz "%d\n"

.balign 4
float_format: .asciz "%f\n"

.balign 4
stack: .skip 12

.text
.global main
main:
	push {r4, r5, r6, r7, r8, r9, r10, lr}
	subs sp, sp, #416
	ldr r1, [r1, #4]
	str r1, [sp, #400] /* get argv[1] and store in sp+400 */

	mov r0, r1
	bl strlen
	str r0, [sp, #404] /* get the length of argv[1] and store in sp+404 */

/* Section 1: this section converts the input string to the integer and operater encoded by 0x8000000X 
 * and below is the list of encoding. Their numeral value also follows the precedence of rpn
 * ): 0x800005 *: 0x800004 /: 0x800003 +: 0x800002 -: 0x800001 (: 0x800000
 */
convert_init:
	ldr r3, addr_of_stack /* This is the stack to hold number chars. when a number reaches its end the stack will be converted to the actual integer */
	adds r2, sp, #200 /* sp+200 to sp+300 is the space for holding the converted integers. r2 is the pointer to the element being operated */ 
	movs r1, #0 /* r1 is the counter for the converted array */
	movs r6, #0 /* r6 is a special indicator to correct the r2 under some special case */
	movs r8, #0 /* r1 is the counter for the stack */
	movs r10, #10 /* r10 holds the multiplier between digits, like 12 = 10*r10 + 2 */
	ldr r7, [sp, #400] /* r7 = argv[1] */
/* the first loop is listed separately for dealing with the negative sign at the first position
 * like -2+3 should be interpreted as (-2) + 3 so 2 should be negated and then - will be ignored 
 */
convert_first_loop:
	ldr r0, [sp, #404]
	cmp r1, r0
	beq final_pop_init
	ldrb r0, [r7, r1]
	cmp r0, #48
	bge num_convert
	cmp r0, #45
	beq parened_negation /* when the first one is -, set the inversion tag */
	b operator_convert

/* and then this is all the later loop */
convert_loop:
	ldr r0, [sp, #404]
	cmp r1, r0
	beq final_pop_init /* if reach the length, convert ends and pop the remaining number in the stack */
	ldrb r0, [r7, r1] /* load a char */
	cmp r0, #48
	bge num_convert /* if the byte >= '0', it's a number */
	b operator_convert /* else it's operator or space */

num_convert:
	subs r0, r0, #48
	strb r0, [r3, r8] /* push the number char into the stack */
	adds r8, r8, #1
	adds r1, r1, #1 /* increment the two counters */
	b convert_loop

operator_convert:
	/* branch to differnt place based on their ascii value */
	cmp r0, #42
	beq push_mul
	cmp r0, #43
	beq push_add
	cmp r0, #45
	beq push_sub
	cmp r0, #47
	beq push_div
	cmp r0, #40
	beq push_leftparen
	cmp r0, #41
	beq push_rightparen
	cmp r0, #46
	beq f_flush_float_stack_init
	adds r1, r1, #1 /* if the char is neither of them, like space, then ignore and continue */
	b convert_loop

push_mul:
	movs r0, #1
	lsl r0, #31
	adds r0, r0, #4 /* r0 = 0x300004, the encoded number */
	cmp r8, #0
	beq push_mul_no_pop /* case when there is nothing in the stack, namely right after a right parentheses */
	adds r2, r2, #4
	str r0, [r2] /* skip a word and store the encoded operator to the next position. The skiped position is for the poped integer  */
	subs r8, r8, #1 /* r8 - 1 to reach the last number char in the stack */
	movs r9, #0 /* r9 holds the reusult integer */
	movs r4, #1 /* r4 holds the multiplier of the current digit */
	b pop_num_loop
push_mul_no_pop:
	str r0, [r2] /* store in the current position and continue */
	adds r2, r2, #4
	adds r1, r1, #1
	b convert_loop

push_div:
	movs r0, #1
	lsl r0, #31
	adds r0, r0, #3 /* r0 = 0x300003, the encoded number */
	cmp r8, #0
	beq push_div_no_pop /* case when there is nothing in the stack, namely right after a right parentheses */
	adds r2, r2, #4
	str r0, [r2] /* skip a word and store the encoded operator to the next position. The skiped position is for the poped integer  */
	subs r8, r8, #1 /* r8 - 1 to reach the last number char in the stack */
	movs r9, #0 /* r9 holds the reusult integer */
	movs r4, #1 /* r4 holds the multiplier of the current digit */
	b pop_num_loop
push_div_no_pop:
	str r0, [r2] /* store in the current position and continue */
	adds r2, r2, #4
	adds r1, r1, #1
	b convert_loop

push_add:
	movs r0, #1
	lsl r0, #31
	adds r0, r0, #2 /* r0 = 0x300002, the encoded number */
	cmp r8, #0
	beq push_add_no_pop /* case when there is nothing in the stack, namely right after a right parentheses */
	adds r2, r2, #4
	str r0, [r2] /* skip a word and store the encoded operator to the next position. The skiped position is for the poped integer  */
	subs r8, r8, #1 /* r8 - 1 to reach the last number char in the stack */
	movs r9, #0 /* r9 holds the reusult integer */
	movs r4, #1 /* r4 holds the multiplier of the current digit */
	b pop_num_loop
push_add_no_pop:
	str r0, [r2] /* store in the current position and continue */
	adds r2, r2, #4
	adds r1, r1, #1
	b convert_loop

push_sub:
	movs r0, #1
	lsl r0, #31
	adds r0, r0, #1 /* r0 = 0x300001, the encoded number */
	cmp r8, #0
	beq push_sub_no_pop /* case when there is nothing in the stack, namely right after a right parentheses */
	adds r2, r2, #4
	str r0, [r2] /* skip a word and store the encoded operator to the next position. The skiped position is for the poped integer  */
	subs r8, r8, #1 /* r8 - 1 to reach the last number char in the stack */
	movs r9, #0 /* r9 holds the reusult integer */
	movs r4, #1 /* r4 holds the multiplier of the current digit */
	b pop_num_loop
push_sub_no_pop:
	str r0, [r2] /* store in the current position and continue */
	adds r2, r2, #4
	adds r1, r1, #1
	b convert_loop

push_leftparen:
	movs r0, #1
	lsl r0, #31
	str r0, [r2] 
	adds r2, r2, #4
	adds r1, r1, #1		
	ldrb r10, [r7, r1]
	cmp r10, #45 /* check if the next char is - */
	beq parened_negation /* if it is a parenthized negation, invert the number */
	b convert_loop

push_rightparen:
	movs r0, #1
	lsl r0, #31
	adds r0, r0, #5
	cmp r8, #0
	beq push_rightparen_no_pop
	adds r2, r2, #4
	str r0, [r2] /* skip a word and store the encoded operator to the next position. The skiped position is for the poped integer */
	subs r8, r8, #1 /* r8 - 1 to reach the last number char in the stack */
	movs r9, #0 /* r9 holds the reusult integer */
	movs r4, #1 /* r4 holds the multiplier of the current digit */
	ldr r0, [sp, #404]
	subs r0, r0, #1
	cmp r1, r0
	beq final_pop_init_paran
	b pop_num_loop
push_rightparen_no_pop:
	str r0, [r2] /* store in the current position and continue */
	adds r2, r2, #4
	adds r1, r1, #1
	b convert_loop

parened_negation:
	movs r5, #1 /* set the negation tag to 1 */
	adds r1, r1, #1 /* skip the - char */
	cmp r8, #0 /* continue if the stack is empty */
	beq convert_loop
	movs r9, #0 /* else pop the stack */
	movs r4, #1
	b pop_num_loop

/* if the last char is right paren, fix the address by adding r1 by 1 and moving r6 a 4. r6 will later added to r2 to fix the address */
final_pop_init_paran:
	adds r1, r1, #1
	movs r6, #4
	b pop_num_loop
/* normal initializtion process for the final pop */
final_pop_init:
	adds r2, r2, #4
	subs r8, r8, #1
	movs r9, #0
	movs r4, #1

pop_num_loop:
	mov r10, #10
	cmp r8, #0
	blt operator_convert_cont1 /* if r8 reach 0 the pop ends */
	ldrb r0, [r3, r8] /* read a byte from stack */
	mul r0, r0, r4 /* multiply by the digit multiplier */
	add r9, r9, r0 /* add to the result */
	mul r4, r4, r10 /* after each bit the multiplier is multiplied by 10 */
	sub r8, #1
	b pop_num_loop
operator_convert_cont1:
	cmp r5, #1
	beq flip_number /* if te negation tag is set, branch to negate the number */
operator_convert_cont2:
	subs r2, r2, #4
	str r9, [r2] /* previously r2 points to the later opeartor, move it back to the skipped space andnstore */
	ldr r0, [sp, #404]
	cmp r1, r0
	beq to_rpn_init /* if this the last pop at the end of the input string, the conversion ends */
	adds r2, r2, #8
	adds r1, r1, #1		
	movs r8, #0
	b convert_loop /* increment the counters, reset the stack counter and continue */

flip_number:
	rsbs r9, r9, #0 /* -r9 = 0-r9 */
	movs r5, #0 /* clear the negation tag */
	b operator_convert_cont2



/* This section converts the integer arrary into the rpn order and store into a doubly linked list */
to_rpn_init:
	add r2, r2, r6 /* correst the end of array by adding r6. the right paren will set r6 to 4 so r2 will move to the next word */
	str r2, [sp, #408] /* store the end of array */
	adds r2, sp, #196 /* head of array -4 since adding r2 happens before loading */
	movs r0, #1
	lsl r0, #31
	str r0, [sp, #300] /* put a 0x800000 at the head of the stack to prevent overflow */
	str r0, [sp, #412] /* 0x800000 is also used in line 143 to check if a element is an operater */
	movs r3, sp /* sp[0-200] is for the doubly linked list and r3 is the pointer to the current node */
	adds r4, sp, #200
	adds r4, r4, #100 /* temporal stack for operators */

to_rpn_loop:
	adds r2, r2, #4
	ldr r0, [r2]
	lsr r0, #3
	lsl r0, #3 /* right shit 3 and then left shift 3 to clear the last 3 bits */
	ldr r1, [sp, #412]
	add r0, r0, r1 /* r3 + 0x800000 */
	cmp r0, #0 /* only 0x80000000 + 0x80000000 = 0, so this will select all the operators */
	beq operator_handle
	ldr r0, [r2]
	/* this section creates the node for the number */
	str r0, [r3] /* store number */
	mov r0, r3
	adds r0, #12
	str r0, [r3, #4] /* addr of next node */
	subs r0, #24
	str r0, [r3, #8] /* addr of last node */
	adds r3, r3, #12 /* node ends, increment r3 by 3 words */
	ldr r0, [sp, #408]
	cmp r2, r0
	beq to_rpn_final_pop /* if reach the end of the array, pop all operator left */
	b to_rpn_loop

operator_handle:
	ldr r0, [r2]
	lsl r0, #1
	cmp r0, #10
	beq rightparen_pop /* if right paren, pop operators until reaching left paren */
	cmp r0, #0
	beq leftparen_push /* if left paren, simply push it without considering precedence */
	ldr r0, [r2]
operator_stack_pop_loop:
	ldr r1, [r4]
	cmp r0, r1
	ble pop_operator /* if the current stack top has higher precedence, pop it */
	adds r4, r4, #4 /* pop ends. push the current operator into the stack */
	str r0, [r4]
	b to_rpn_loop
pop_operator:
	str r1, [r3] /* store operator */
	mov r1, r3
	adds r1, #12
	str r1, [r3, #4] /* addr of next node */
	subs r1, #24
	str r1, [r3, #8] /* addr of last node */
	adds r3, r3, #12 
	subs r4, r4, #4 /* decrease the stack pointer */
	b operator_stack_pop_loop /* continue checking the stack top */

/* simply push the left paren */
leftparen_push:
	ldr r0, [r2]
	adds r4, r4, #4
	str r0, [r4]
	b to_rpn_loop

/* pop until left paeren */
rightparen_pop:
	ldr r0, [r4]
	lsl r0, #1
	cmp r0, #0
	beq rightparen_pop_cont /* touch left paren. stop popping */
	ldr r0, [r4]
	str r0, [r3] /* store operator */
	mov r0, r3
	adds r0, #12
	str r0, [r3, #4] /* addr of next node */
	subs r0, #24
	str r0, [r3, #8] /* addr of last node */
	adds r3, r3, #12
	subs r4, r4, #4
	b rightparen_pop
rightparen_pop_cont:
	subs r4, r4, #4 /* skip left paren */
	ldr r0, [sp, #408]
	cmp r2, r0
	beq to_rpn_final_pop /* if reaching the end, go to final pop */
	b to_rpn_loop

/* at the end pop all the operators out */
to_rpn_final_pop:
	adds r0, sp, #200
	adds r0, r0, #100
	cmp r0, r4
	beq rpn_calc_init /* if reach the end of stack, start calculation */
	ldr r0, [r4]
	cmp r0, #0 /* this is for preventing overflow. the length of the array can be larger then the number of nodes due to nested parentheses. */
	beq rpn_calc_init
	str r0, [r3] /* store operator */
	mov r0, r3
	adds r0, #12
	str r0, [r3, #4] /* addr of next node */
	subs r0, #24
	str r0, [r3, #8] /* addr of last node */
	adds r3, r3, #12
	subs r4, r4, #4
	b to_rpn_final_pop



/* This section performs the rpn calculation */
rpn_calc_init:
	mov r7, sp /* r7 is the pointer to the current node being operated */
	movs r0, #0
	subs r3, r3, #12 /* move r3 to the last node */
	str r0, [r7, #8] /* null terminate the lastNode in the first node */
	str r0, [r3, #4] /* null terminate the nextNode in the last node */
rpn_calc_loop:
	ldr r1, [r7] /* get the first element */
	ldr r0, [r7, #4]  /* get *nextNode */
	ldr r2, [r0] /* get the second element */
	ldr r0, [r0, #4] /* get *nextNode */
	ldr r3, [r0] /* get the third element */
	cmp r3, #0 
	blt operate_judge /* if r3 is an operator, do operation */
	ldr r0, [r7,#4]
	mov r7, r0 /* else go to the next node */
	b rpn_calc_loop

/* judge the type of operations */
operate_judge:
	mov r8, r0 /* store the third node in r8 */
	lsl r3, #1
	lsr r3, #1
	cmp r3, #4
	beq multiply
	cmp r3, #3
	beq divide
	cmp r3, #2
	beq add
	b substract
/* operation ends */
operate_cont:
	str r1, [r7] /* store the result to the first node */
	mov r0, r8 /* restore the third node from r8 */
	ldr r0, [r0, #4]
	cmp r0, #0 /* if the nextNode of the third node is 0, the program ends */
	beq end
	str r0, [r7, #4] /* copy the nextNode of the third node to the nextNode of the first node to connect to the fourth node */
	str r7, [r0, #8] /* similarly connect the lastNode of the fourth node back to the first node */
	ldr r0, [r7, #8]
	cmp r0, #0 /* if currently at the first node, go back directly */
	beq rpn_calc_loop
	mov r7, r0 /* else move the current pointer back by one node */
	b rpn_calc_loop

/* below are differnt types of operations */
multiply:
	mul r1, r1, r2
	b operate_cont

/* there is no built-in integer division in armv7
 * so a loop is implemented to calculate the integer division */
divide:
	movs r0, #0
	movs r3, #0
	cmp r1, #0
	blt flip_r1 /* if dividend is negative, add the flip tag by 1 and filp dividend */
divide_cont:
	cmp r2, #0
	blt flip_r2 /* if divider is negative, add the flip tag by 1 and filp divider */
	b divide_loop_check
divide_loop:
	adds r0, #1
	sub r1, r1, r2
divide_loop_check:
	cmp r1, r2
	bhs divide_loop
	cmp r3, #1 /* if the flip tag is 1, there is one negative number and the result is negative */
	beq flip_result
	mov r1, r0
	b operate_cont
flip_r1:
	rsbs r1, r1, #0
	adds r3, r3, #1
	b divide_cont
flip_r2:
	rsbs r2, r2, #0
	adds r3, r3, #1
	b divide_loop_check
flip_result:
	rsbs r0, r0, #0
	mov r1, r0
	b operate_cont

add:
	add r1, r1, r2
	b operate_cont

substract:
	sub r1, r1, r2
	b operate_cont

/* the progarm ends */
end:
	ldr r0, addr_of_int_format
	bl printf /* print the result */
	adds sp, sp, #416
	pop {r4, r5, r6, r7, r8, r9, r10, lr} /* recover everything */
	bx lr


/* Below are the program for float point */


f_flush_float_stack_init:
	cmp r8, #0
	blt f_convert_init
	strb r0, [r3, r8] /* set r8th byte to 0 */
	subs r8, r8, #1
	b f_flush_float_stack_init
f_convert_init:
	ldr r3, addr_of_stack 
	adds r2, sp, #200 /* sp+200 to sp+300 is the space for holding the converted integers. r2 is the pointer to the element being operated */ 
	movs r1, #0 /* r1 is the counter for the converted array */
	movs r6, #0 /* r6 is a special indicator to correct the r2 under some special case */
	movs r8, #0 /* r1 is the counter for the stack */
	movs r10, #10 /* r10 holds the multiplier between digits, like 12 = 10*r10 + 2 */
	ldr r7, [sp, #400] /* r7 = argv[1] */

/* the first loop is listed separately for dealing with the negative sign at the first position
 * like -2+3 should be interpreted as (-2) + 3 so 2 should be negated and then - will be ignored 
 */
f_convert_first_loop:
	ldr r0, [sp, #404]
	cmp r1, r0
	beq f_final_pop_init
	ldrb r0, [r7, r1]
	cmp r0, #48
	bge f_num_convert
	cmp r0, #45
	beq f_parened_negation /* when the first one is -, set the inversion tag */
	b f_operator_convert

/* and then this is all the later loop */
f_convert_loop:
	ldr r0, [sp, #404]
	cmp r1, r0
	beq f_final_pop_init /* if reach the length, convert ends and pop the remaining number in the stack */
	ldrb r0, [r7, r1] /* load a char */
	cmp r0, #48
	bge f_num_convert /* if the byte >= '0', it's a number */
	cmp r0, #46
	beq f_num_convert /* if it is decimal point, also push it into the stack */
	b f_operator_convert /* else it's operator or space */

f_num_convert:
	strb r0, [r3, r8] /* push the number char into the stack */
	adds r8, r8, #1
	adds r1, r1, #1 /* increment the two counters */
	b f_convert_loop

f_operator_convert:
	/* branch to differnt place based on their ascii value */
	cmp r0, #42
	beq f_push_mul
	cmp r0, #43
	beq f_push_add
	cmp r0, #45
	beq f_push_sub
	cmp r0, #47
	beq f_push_div
	cmp r0, #40
	beq f_push_leftparen
	cmp r0, #41
	beq f_push_rightparen
	adds r1, r1, #1 /* if the char is neither of them, like space, then ignore and continue */
	b f_convert_loop

f_push_mul:
	movs r0, #1
	lsl r0, #31
	adds r0, r0, #4 /* r0 = 0x300004, the encoded number */
	cmp r8, #0
	beq f_push_mul_no_pop /* case when there is nothing in the stack, namely right after a right parentheses */
	adds r2, r2, #4
	str r0, [r2] /* skip a word and store the encoded operator to the next position. The skiped position is for the poped integer  */
	subs r8, r8, #1 /* r8 - 1 to reach the last number char in the stack */
	movs r9, #0 /* r9 holds the reusult integer */
	movs r4, #1 /* r4 holds the multiplier of the current digit */
	b f_pop_num_loop
f_push_mul_no_pop:
	str r0, [r2] /* store in the current position and continue */
	adds r2, r2, #4
	adds r1, r1, #1
	b f_convert_loop

f_push_div:
	movs r0, #1
	lsl r0, #31
	adds r0, r0, #3 /* r0 = 0x300003, the encoded number */
	cmp r8, #0
	beq f_push_div_no_pop /* case when there is nothing in the stack, namely right after a right parentheses */
	adds r2, r2, #4
	str r0, [r2] /* skip a word and store the encoded operator to the next position. The skiped position is for the poped integer  */
	subs r8, r8, #1 /* r8 - 1 to reach the last number char in the stack */
	movs r9, #0 /* r9 holds the reusult integer */
	movs r4, #1 /* r4 holds the multiplier of the current digit */
	b f_pop_num_loop
f_push_div_no_pop:
	str r0, [r2] /* store in the current position and continue */
	adds r2, r2, #4
	adds r1, r1, #1
	b f_convert_loop

f_push_add:
	movs r0, #1
	lsl r0, #31
	adds r0, r0, #2 /* r0 = 0x300002, the encoded number */
	cmp r8, #0
	beq f_push_add_no_pop /* case when there is nothing in the stack, namely right after a right parentheses */
	adds r2, r2, #4
	str r0, [r2] /* skip a word and store the encoded operator to the next position. The skiped position is for the poped integer  */
	subs r8, r8, #1 /* r8 - 1 to reach the last number char in the stack */
	movs r9, #0 /* r9 holds the reusult integer */
	movs r4, #1 /* r4 holds the multiplier of the current digit */
	b f_pop_num_loop
f_push_add_no_pop:
	str r0, [r2] /* store in the current position and continue */
	adds r2, r2, #4
	adds r1, r1, #1
	b f_convert_loop

f_push_sub:
	movs r0, #1
	lsl r0, #31
	adds r0, r0, #1 /* r0 = 0x300001, the encoded number */
	cmp r8, #0
	beq f_push_sub_no_pop /* case when there is nothing in the stack, namely right after a right parentheses */
	adds r2, r2, #4
	str r0, [r2] /* skip a word and store the encoded operator to the next position. The skiped position is for the poped integer  */
	subs r8, r8, #1 /* r8 - 1 to reach the last number char in the stack */
	movs r9, #0 /* r9 holds the reusult integer */
	movs r4, #1 /* r4 holds the multiplier of the current digit */
	b f_pop_num_loop
f_push_sub_no_pop:
	str r0, [r2] /* store in the current position and continue */
	adds r2, r2, #4
	adds r1, r1, #1
	b f_convert_loop

f_push_leftparen:
	movs r0, #1
	lsl r0, #31
	str r0, [r2] 
	adds r2, r2, #4
	adds r1, r1, #1		
	ldrb r10, [r7, r1]
	cmp r10, #45 /* check if the next char is - */
	beq f_parened_negation /* if it is a parenthized negation, invert the number */
	b f_convert_loop

f_push_rightparen:
	movs r0, #1
	lsl r0, #31
	adds r0, r0, #5
	cmp r8, #0
	beq f_push_rightparen_no_pop
	adds r2, r2, #4
	str r0, [r2] /* skip a word and store the encoded operator to the next position. The skiped position is for the poped integer */
	subs r8, r8, #1 /* r8 - 1 to reach the last number char in the stack */
	movs r9, #0 /* r9 holds the reusult integer */
	movs r4, #1 /* r4 holds the multiplier of the current digit */
	ldr r0, [sp, #404]
	subs r0, r0, #1
	cmp r1, r0
	beq f_final_pop_init_paran
	b f_pop_num_loop
f_push_rightparen_no_pop:
	str r0, [r2] /* store in the current position and continue */
	adds r2, r2, #4
	adds r1, r1, #1
	b f_convert_loop

f_parened_negation:
	movs r5, #1 /* set the negation tag to 1 */
	adds r1, r1, #1 /* skip the - char */
	cmp r8, #0 /* continue if the stack is empty */
	beq f_convert_loop
	movs r9, #0 /* else pop the stack */
	movs r4, #1
	b f_pop_num_loop

	/* if the last char is right paren, fix the address by adding r1 by 1 and moving r6 a 4. r6 will later added to r2 to fix the address */
f_final_pop_init_paran:
	adds r1, r1, #1
	movs r6, #4
	b f_pop_num_loop
/* normal initializtion process for the final pop */
f_final_pop_init:
	adds r2, r2, #4
	subs r8, r8, #1
	movs r9, #0
	movs r4, #1

f_pop_num_loop:
	push {r0, r1, r2, r3}
	ldr r0, addr_of_stack
	bl atof
	vcvt.f32.f64 s0, d0
	vmov r9, s0
	pop {r0, r1, r2, r3}
	movs r0, #0
/* the stack must be cleaned before using again, or char will remain inside and interfere with later atof() */
f_flush_float_stack:
	cmp r8, #0
	blt f_operator_convert_cont1
	strb r0, [r3, r8] /* set r8th byte to 0 */
	subs r8, r8, #1
	b f_flush_float_stack
f_operator_convert_cont1:
	cmp r5, #1
	beq f_flip_number /* if te negation tag is set, branch to negate the number */
f_operator_convert_cont2:
	subs r2, r2, #4
	str r9, [r2] /* previously r2 points to the later opeartor, move it back to the skipped space andnstore */
	ldr r0, [sp, #404]
	cmp r1, r0
	beq f_to_rpn_init /* if this the last pop at the end of the input string, the conversion ends */
	adds r2, r2, #8
	adds r1, r1, #1		
	movs r8, #0
	b f_convert_loop /* increment the counters, reset the stack counter and continue */

f_flip_number:
	movs r5, #0 /* clear the negation tag */
	vmov s1, r5
	vsub.f32 s0, s1, s0 /* -s0 = 0-s0 */
	vmov r9, s0
	b f_operator_convert_cont2

/* -------- */

/* This section converts the integer arrary into the rpn order and store into a doubly linked list */
f_to_rpn_init:
	add r2, r2, r6 /* correst the end of array by adding r6. the right paren will set r6 to 4 so r2 will move to the next word */
	str r2, [sp, #408] /* store the end of array */
	adds r2, sp, #196 /* head of array -4 since adding r2 happens before loading */
	movs r0, #1
	lsl r0, #31
	str r0, [sp, #300] /* put a 0x800000 at the head of the stack to prevent overflow */
	str r0, [sp, #412] /* 0x800000 is also used in line 143 to check if a element is an operater */
	movs r3, sp /* sp[0-200] is for the doubly linked list and r3 is the pointer to the current node */
	adds r4, sp, #200
	adds r4, r4, #100 /* temporal stack for operators */

f_to_rpn_loop:
	adds r2, r2, #4
	ldr r0, [r2]
	lsr r0, #3
	lsl r0, #3 /* right shit 3 and then left shift 3 to clear the last 3 bits */
	ldr r1, [sp, #412]
	add r0, r0, r1 /* r3 + 0x800000 */
	cmp r0, #0 /* only 0x80000000 + 0x80000000 = 0, so this will select all the operators */
	beq f_operator_handle
	ldr r0, [r2]
	/* this section creates the node for the number */
	str r0, [r3] /* store number */
	mov r0, r3
	adds r0, #12
	str r0, [r3, #4] /* addr of next node */
	subs r0, #24
	str r0, [r3, #8] /* addr of last node */
	adds r3, r3, #12 /* node ends, increment r3 by 3 words */
	ldr r0, [sp, #408]
	cmp r2, r0
	beq f_to_rpn_final_pop /* if reach the end of the array, pop all operator left */
	b f_to_rpn_loop

f_operator_handle:
	ldr r0, [r2]
	lsl r0, #1
	cmp r0, #10
	beq f_rightparen_pop /* if right paren, pop operators until reaching left paren */
	cmp r0, #0
	beq f_leftparen_push /* if left paren, simply push it without considering precedence */
	ldr r0, [r2]
f_operator_stack_pop_loop:
	ldr r1, [r4]
	cmp r0, r1
	ble f_pop_operator /* if the current stack top has higher precedence, pop it */
	adds r4, r4, #4 /* pop ends. push the current operator into the stack */
	str r0, [r4]
	b f_to_rpn_loop
f_pop_operator:
	str r1, [r3] /* store operator */
	mov r1, r3
	adds r1, #12
	str r1, [r3, #4] /* addr of next node */
	subs r1, #24
	str r1, [r3, #8] /* addr of last node */
	adds r3, r3, #12 
	subs r4, r4, #4 /* decrease the stack pointer */
	b f_operator_stack_pop_loop /* continue checking the stack top */

/* simply push the left paren */
f_leftparen_push:
	ldr r0, [r2]
	adds r4, r4, #4
	str r0, [r4]
	b f_to_rpn_loop

/* pop until left paeren */
f_rightparen_pop:
	ldr r0, [r4]
	lsl r0, #1
	cmp r0, #0
	beq f_rightparen_pop_cont /* touch left paren. stop popping */
	ldr r0, [r4]
	str r0, [r3] /* store operator */
	mov r0, r3
	adds r0, #12
	str r0, [r3, #4] /* addr of next node */
	subs r0, #24
	str r0, [r3, #8] /* addr of last node */
	adds r3, r3, #12
	subs r4, r4, #4
	b f_rightparen_pop
f_rightparen_pop_cont:
	subs r4, r4, #4 /* skip left paren */
	ldr r0, [sp, #408]
	cmp r2, r0
	beq f_to_rpn_final_pop /* if reaching the end, go to final pop */
	b f_to_rpn_loop

/* at the end pop all the operators out */
f_to_rpn_final_pop:
	adds r0, sp, #200
	adds r0, r0, #100
	cmp r0, r4
	beq f_rpn_calc_init /* if reach the end of stack, start calculation */
	ldr r0, [r4]
	cmp r0, #0 /* this is for preventing overflow. the length of the array can be larger then the number of nodes due to nested parentheses. */
	beq f_rpn_calc_init
	ldr r0, [r4]
	str r0, [r3] /* store operator */
	mov r0, r3
	adds r0, #12
	str r0, [r3, #4] /* addr of next node */
	subs r0, #24
	str r0, [r3, #8] /* addr of last node */
	adds r3, r3, #12
	subs r4, r4, #4
	b f_to_rpn_final_pop

/* ------ */

/* This section performs the rpn calculation */
f_rpn_calc_init:
	mov r7, sp /* r7 is the pointer to the current node being operated */
	movs r0, #0
	subs r3, r3, #12 /* move r3 to the last node */
	str r0, [r7, #8] /* null terminate the lastNode in the first node */
	str r0, [r3, #4] /* null terminate the nextNode in the last node */
f_rpn_calc_loop:
	ldr r1, [r7] /* get the first element */
	ldr r0, [r7, #4]  /* get *nextNode */
	ldr r2, [r0] /* get the second element */
	ldr r0, [r0, #4] /* get *nextNode */
	ldr r3, [r0] /* get the third element */
	cmp r3, #0 
	blt f_operate_judge /* if r3 is an operator, do operation */
	ldr r0, [r7,#4]
	mov r7, r0 /* else go to the next node */
	b f_rpn_calc_loop

/* judge the type of operations */
f_operate_judge:
	vmov s4, r1
	vmov s5, r2
	mov r8, r0 /* store the third node in r8 */
	lsl r3, #1
	lsr r3, #1
	cmp r3, #4
	beq f_multiply
	cmp r3, #3
	beq f_divide
	cmp r3, #2
	beq f_add
	b f_substract
/* operation ends */
f_operate_cont:
	vmov r1, s4
	str r1, [r7] /* store the result to the first node */
	mov r0, r8 /* restore the third node from r8 */
	ldr r0, [r0, #4]
	cmp r0, #0 /* if the nextNode of the third node is 0, the program ends */
	beq f_end
	str r0, [r7, #4] /* copy the nextNode of the third node to the nextNode of the first node to connect to the fourth node */
	str r7, [r0, #8] /* similarly connect the lastNode of the fourth node back to the first node */
	ldr r0, [r7, #8]
	cmp r0, #0 /* if currently at the first node, go back directly */
	beq f_rpn_calc_loop
	mov r7, r0 /* else move the current pointer back by one node */
	b f_rpn_calc_loop

/* below are differnt types of operations */
f_multiply:
	vmul.f32 s4, s4, s5
	b f_operate_cont

/* there is no built-in integer division in armv7
 * so a loop is implemented to calculate the integer division */
f_divide: 
	vdiv.f32 s4, s4, s5
	b f_operate_cont

f_add:
	vadd.f32 s4, s4, s5
	b f_operate_cont

f_substract:
	vsub.f32 s4, s4, s5
	b f_operate_cont

/* the progarm ends */
f_end:
	ldr r0, addr_of_float_format
	vmov s1, r1
	vcvt.f64.f32 d0, s1
	vmov r2, r3, d0
	bl printf /* print the result */
	adds sp, sp, #416
	pop {r4, r5, r6, r7, r8, r9, r10, lr} /* recover everything */
	bx lr

addr_of_int_format: .word int_format
addr_of_float_format: .word float_format
addr_of_stack: .word stack
