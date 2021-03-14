//Allister Liu
ldxr x2,[x20,#0]
ldxr x3,[x21,#0]
sub x4,x2,x3
cbz x4, end

again_1:
stxr x2, x9, [x21]
cbnz x9, again1
again_2:
stxr x3, x9, [x20]
cbnz x9, again2

end: bx lr
