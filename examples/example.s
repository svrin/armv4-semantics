sum:
	add	r0, r0, r1
	bx	lr
subtract:
    sub r0, r0, r1
    bx	lr
lower:
    subs r2, r0, r1
    moveq r0, r1
    bx	lr
main:
    mov r0, #2
    mov r1, #3
    mov r2, r0
    mov r0, #5
    bl sumzu
    bl subtract
    bl lower
