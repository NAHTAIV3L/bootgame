[BITS 16]
[ORG 0x7C00]

%include "macros.asm"

    jmp 0x00:start
start:
    cli
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7C00
    mov ax, 0xA000
    mov es, ax

    ;setting 320x200 256 colors graphics mode
    mov ax, 0x0013
    sti
    int 0x10
    cli

keyboardcheckloop:
    xor ax, ax
    in al, 0x64
    bt ax, 1
    jc keyboardcheckloop

    mov al, 0xF4
    out 0x60, al

mainloop:
    call draw

    mov ax, [enemyx]
    mov bx, [playerx]
    call enemyai
    mov [enemyx], ax

    mov ax, [enemyy]
    mov bx, [playery]
    call enemyai
    mov [enemyy], ax


    MOVEMENT


    BOUNDARIES

    call collision

    WAIT_FOR_RTC
    jmp mainloop

reset:
    xor ax, ax
    mov [playerx], ax
    mov [playery], ax
    mov ax, 100
    mov [enemyx], ax
    mov [enemyy], ax
    ret


drawplayer:
    xor ax, ax
    mov [i], ax
.playerdrawloop:
    mov ax, RES_X
    mov bx, [si]
    add bx, [i]
    push dx
    mul bx
    pop dx
    add ax, [di]
    push di
    mov di, ax
    mov al, [color]
    mov cx, dx
    repe stosb
    pop di

    mov ax, [i]
    inc ax
    mov [i], ax
    cmp ax, dx
    jl .playerdrawloop
    ret

shutdown:
    mov ax, 0x1000
    mov ax, ss
    mov sp, 0xf000
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
    ret

enemyai:
    add ax, HALFE
    add bx, HALFP
    cmp ax, bx
    je .cont
    jl .less
    dec ax
    jmp .cont
.less:
    inc ax
.cont:
    sub ax, HALFE
    ret

draw:
    CLS

    mov si, playery
    mov di, playerx
    mov dx, PLAYER
    mov byte [color], GREEN
    call drawplayer

    mov si, enemyy
    mov di, enemyx
    mov dx, ENEMY
    mov byte [color], RED
    call drawplayer
    ret

collision:
    xor cx, cx
    mov ax, [playerx]
    mov bx, [enemyx]
    add bx, ENEMY
    cmp ax, bx
    jge .cont1
    inc cx
.cont1:
    add ax, PLAYER
    sub bx, ENEMY
    cmp ax, bx
    jle .cont2
    inc cx
.cont2:
    mov ax, [playery]
    mov bx, [enemyy]
    add bx, ENEMY
    cmp ax, bx
    jge .cont3
    inc cx
.cont3:
    add ax, PLAYER
    sub bx, ENEMY
    cmp ax, bx
    jle .cont4
    inc cx
.cont4:
    cmp cx, 4
    jne .cont5
.rlop:
    call draw
    WAIT_FOR_RTC
    in al, 0x60
    cmp al, R
    je .reset
    cmp al, Q
    jne .rlop
    call shutdown
.reset:
    call reset
.cont5:
    ret



i dw 0
playerx dw 0
playery dw 0
xvp dw 0
xvn dw 0
yvp dw 0
yvn dw 0
enemyx  dw 100
enemyy  dw 100
color db 0
timer_current dw 0
    times 510-($-$$) db 0x00
    dw 0xAA55
