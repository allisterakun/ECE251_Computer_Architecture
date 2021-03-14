.data

.balign 4
format: .asciz "%s"

.balign 4
test: .asciz "1+2*(3-5)"

.balign 4
zero: .asciz "0"

.balign 4
one: .asciz "1"

.balign 4
two: .asciz "2"

.balign 4
three: .asciz "3"

.balign 4
four: .asciz "4"

.balign 4
five: .asciz "5"

.balign 4
six: .asciz "6"

.balign 4
seven: .asciz "7"

.balign 4
eight: .asciz "1"

.balign 4
nine: .asciz "9"

.text

.global main
main:
    ldr r1, address_of_return
    str lr, [r1]
    subs sp, sp, #100

    ldr r2, address_of_test
    mov r3, #0
    str r1, [r0, +r3]
    b digit_judge

digit_judge:
    cmp r2, one
    beq
    cmp r2, two
    beq
    cmp r2, three
    beq
    cmp r2, four
    beq
    cmp r2, five
    beq
    cmp r2, six
    beq
    cmp r2, seven
    beq
    cmp r2, nine
    beq
    cmp r2, zero
    beq

