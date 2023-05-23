
%define RES_X 320
%define RES_Y 200
%define BLACK 0x08
%define GREEN 0x0A
%define RED 0x0C
%define PLAYER  0x20
%define ENEMY   0x08
%define HALFP   0x10
%define HALFE   0x04
%define W 0x11
%define D 0x20
%define A 0x1E
%define S 0x1F
%define R 0x13
%define Q 0x10


%macro CLS 0
    xor di, di
    mov al, BLACK
    mov cx, 0xFA00
    repe stosb
%endmacro

%macro WAIT_FOR_RTC 0
    ;synchronizing game to real time clock (18.2 ticks per sec)
.sync:
    xor ah,ah
    sti
    int 0x1a ;returns the current tick count in dx
    cli
    cmp word [timer_current], dx
je .sync ;reloop until new tick
    mov word [timer_current], dx ;save new tick value
%endmacro


%macro BOUNDARIES 0
    cmp bx, 0
    jge .y0end
    mov word [playery], 0
.y0end:
    add bx, PLAYER
    cmp bx, RES_Y
    jle .yend
    mov word [playery], RES_Y - PLAYER
.yend:
    mov bx, [playerx]
    cmp bx, 0
    jge .x0end
    mov word [playerx], 0
.x0end:
    add bx, PLAYER
    cmp bx, RES_X
    jle .xend
    mov word [playerx], RES_X - PLAYER
.xend:
%endmacro

%macro MOVEMENT 0
    in al, 0x60

    mov bx, [playerx]
    mov cx, bx
    add cx, 3
    cmp al, D
    cmove bx, cx
    sub cx, 6
    cmp al, A
    cmove bx, cx
    mov [playerx], bx
    mov bx, [playery]
    mov cx, bx
    add cx, 3
    cmp al, S
    cmove bx, cx
    sub cx, 6
    cmp al, W
    cmove bx, cx
    mov [playery], bx
    cmp al, Q
    jne .nosd
    call shutdown
.nosd:
%endmacro
