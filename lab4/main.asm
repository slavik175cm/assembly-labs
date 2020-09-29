model small
.stack 100h
.data
s db 102 dup(?)
pi db 102 dup(0)
no db "no$"
yes db "yes$"
len1 dw 0
len dw 0
symbol db ?
.code
;include my_funcs.asm

read_char proc C near
arg outo:word
uses ax, bx
    mov bx, outo
    mov ah, 08h
    int 21h
    mov byte ptr [bx], al
    ret
endp

print_char proc C near
arg sym:word
uses ax, dx
    mov ah, 02h
    mov dl, offset sym
    int 21h
    ret
endp

print_string proc C near
arg string:word
uses ax, dx
    mov ah, 09h
    mov dx, string
    int 21h
    ret
endp

read_string proc C near
arg string:word, leng:word
uses ax, bx
    mov bx, string
    mov si, 0

    read_st:
        call read_char C, offset symbol
        cmp symbol, 13
        je continue1

        cmp symbol, 10
        je continue1

        mov al, symbol
        mov byte ptr [bx + si], al
        
        inc si
        call print_char C, word ptr symbol
        jmp read_st

    continue1:
    mov byte ptr [bx + si], '$'
    
    mov bx, leng
    mov [bx], si
    ret
endp

print_enter proc C near
uses ax, dx
    mov ah, 02h
    mov dl, 0dh
    int 21h
    mov dl, 0ah
    int 21h
    ret
endp

start:
mov ax, @data
mov ds, ax

call read_string C, offset s, offset len
mov cx, 0
find_sp:
    mov si, cx
    cmp s[si], ' '
    je continue0
    inc cx
    jmp find_sp
continue0:
mov len1, cx

mov cx, len
dec cx
;inc cx

mov ax, 1 ; ax - i bx - j
mov bx, 0
cycle:
    mov si, word ptr ax
    dec si
    mov bl, pi[si]
    while1:
        cmp bx, 0
        je continue2

        mov si, bx
        mov dl, s[si]
        mov si, ax
        cmp s[si], dl
        je continue2

        mov si, bx
        dec si
        mov bl, pi[si] 
        jmp while1

    continue2:
    mov si, bx
    mov dl, s[si]
    mov si, ax
    cmp s[si], dl
    jne continue3
    inc bx
    continue3:
    mov si, ax
    mov pi[si], bl

    ;call print_uint16 C, word ptr pi[si]
    mov dl, byte ptr len1
    cmp pi[si], dl
    je to_yes

    inc ax
    loop cycle

call print_enter
call print_string C, offset no
mov ah, 4ch
int 21h

to_yes:
    call print_enter
    call print_string C, offset yes
    mov ah, 4ch
    int 21h

end start