//Allister Liu
loop:
ldxr x10,[x20,#0]
addi x10,x10,#1
stxr x10,x9,[x20,#0]
cbnz x9, loop

end: bx lr
