.text
.global main

main: 
	mov r2, #123
	mov r0, #0

one_check:
	cmp r2, #1
	beq end

odd_even:
	and r4, r2, #1
	cmp r4, #1
	bne even

odd:
	add r2, r2, LSL #1
	add r2, r2, #1
	add r0, r0, #1
	b one_check

even:
	mov r2, r2, ASR #1
	add r0, r0, #1
	b one_check

end:
	bx lr 
        




