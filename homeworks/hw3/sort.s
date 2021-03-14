//Allister Liu
addi x0,xzr,xzr                //i=0
addi x2,xzr,xzr                //flag=0

loop1:
addi x3,xzr,#9
subs xzr,x0,x3
b.ge end
addi x1,xzr,xzr
sub x3,x3,x0
b loop2

loop:
addi x0,x0,#1
cbz x2,end
b loop1

loop2:
subs xzr,x1,x3
b.ge loop
add x4,x1,xzr
lsl x4,x4,#3
add x4,x4,x20
addi x5,x1,#1
lsl x5,x5,#3
add x5,x5,x20
ldxr x6,[x4,#0]
ldxr x7,[x5,#0]
subs xzr,x6,x7
b.gt swap
addi x1,x1,#1
b loop2

swap:
stxr x7,x9,[x4]
cbnz x9,swap
swaap:
stxr x6,x9,[x5,#0]
cbnz x9,swaap
addi x1,x1,#1
addi x2,x2,#1
b loop2

end:
bx lr
