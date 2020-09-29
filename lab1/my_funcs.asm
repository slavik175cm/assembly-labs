.model small

.code

print_uint16 proc C near
arg number:word
uses ax, bx, cx, dx    
    mov ax, number
    mov cx, 0
    cycle:
        inc cx

        mov dx, 0
        mov bx, 10
        div bx

        add dx, 48d

        push dx

        cmp ax, 0d
        je output

        jmp cycle

    output:
        printcycle:
            mov ah, 02h
            pop bx
            mov dl, bl
            int 21h
            loop printcycle
    ret
endp

