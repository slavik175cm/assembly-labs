model small
.stack 100h
.data
a dw 40000
b dw 38
c dw 40000
d dw 23

.code
include my_funcs.asm

start:
mov ax, @data
mov ds, ax

mov ax, a
add ax, c

jb second_case
;call print_uint16 C, ax
mov bx, b
xor bx, d

cmp ax, bx
jne second_case

;first_case:
mov ax, a
or ax, b
or ax, c
add ax, d
jmp to_end

second_case:
    mov bx, b
    and bx, d

    cmp ax, bx
    jne third_case

    mov ax, a
    xor ax, b
    mov bx, c
    xor bx, d
    add ax, bx
    jmp to_end


third_case:
mov ax, a
add ax, d
mov bx, b
or bx, c
and ax, bx

to_end:

call print_uint16 C, ax

mov ah, 4ch
int 21h

end start