//Allister Liu
loop:
subis xzr,x0,#4
b.gt end
add x1,xzr,x0
lsl x1,x1,#3
add x2,x1,x20
add,x3,x1,x21
b swap

swap:
ldxr x4,[x2,#0]
ldxr x5,[x3,#0]

again_1:
stxr x4,x9,[x3]
cbnz x9,again_1

again_2:
stxr x5,x9,[x2,#0]
cbnz x9,again_2
addi x0,x0,#1
b loop

end:
bx lr
