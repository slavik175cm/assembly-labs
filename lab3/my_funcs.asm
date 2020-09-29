.model small

.code

print_int16 proc C near
arg number:word
uses ax  
    test number, 1000000000000000b
    jne write_minus
    jmp next

    write_minus:
        mov ax, 45d
        call print_char C, ax
        sub number, 1
        not number
    next:

    call print_uint16 C, number
    ret
endp

print_uint16 proc C near
arg number:word
uses ax, bx, cx, dx    
    mov ax, number
    mov cx, 0
    cycle2:
        inc cx

        mov dx, 0
        mov bx, 10
        div bx

        add dx, 48d

        push dx

        cmp ax, 0d
        je output

        jmp cycle2

    output:
        printcycle:
            mov ah, 02h
            pop bx
            mov dl, bl
            int 21h
            loop printcycle
    ret
endp


read_char proc C near
;arg output1:word
uses ax
    ;call print_int16 C, output1
    mov ah, 08h
    int 21h
    mov bh, 0
    mov bl, al
    ;mov ah, 0
    ;mov [output1], ax
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

print_enter proc C near
uses ax, dx
    mov ah, 02h
    mov dl, 0dh
    int 21h
    mov dl, 0ah
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

del_symbol proc C near
uses ax, dx    
    mov ah, 02h
    mov dl, 08h
    int 21h 
    mov dl, 20h
    int 21h
    mov ah, 02h
    mov dl, 08h
    int 21h
    ret
endp
