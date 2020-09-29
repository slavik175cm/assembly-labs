model small
.stack 100h
.data
zapros db "input a number",0dh,0ah,"$"
overflow_label db "the number is to big, try again..",0dh,0ah,"$"
division_error_label db "can't divide by zero, try again ",0dh,0ah, "$"
slash db " / $"
equal db " = $"
rem db "remainder: $"
const10 dw 10d
mask_int16 dw 1000000000000000b
.code
include my_funcs.asm

read_int16 proc C near
local belowzero:word, len:word
uses bx, cx, dx

    mov ax, 0
    mov belowzero, 0
    mov len, 0
    main_cycle:

        call read_char ; bl - current digit

        cmp bl, 13d ; jump if enter
        je to_end_trans
        
        cmp bl, 8d 
        je backspace

        cmp bl, 27d
        je escape_trans
        
        cmp bl, 45d ; '-'
        jne continue1
        cmp belowzero, 1
        je main_cycle
        cmp len, 0
        jne main_cycle
        try_minus:
            call print_char C, bx
            mov belowzero, 1
            jmp main_cycle

        continue1:

        cmp bl, 57d
        ja main_cycle ; symbol > 9
        
        cmp bl, '0'
        jb main_cycle ; symbol < 0
        
        cmp ax, 0
        jne continue2
        cmp len, 1
        je main_cycle

        continue2:
        add len, 1
        call print_char C, bx ; printing current digit

        sub bl, 48d
        imul const10
        
        mov cx, mask_int16
        sub cx, 1
        test dx, cx
        jne toomuch

        add ax, bx

        jl toomuch; cf == 1

        jmp main_cycle

    to_end_trans:
        jmp to_end

    main_cycle_trans:
        jmp main_cycle

    escape_trans:
        jmp escape

    backspace:
        cmp len, 0
        jne skip_deleting_minus1
        cmp belowzero, 1
        jne main_cycle_trans
        mov belowzero, 0
        call del_symbol
        jmp main_cycle_trans

        skip_deleting_minus1:
        sub len, 1
        call del_symbol
        
        idiv const10
        mov dx, 0

        jmp main_cycle

    escape:
        cmp len, 0
        jne skip_deleting_minus2
        cmp belowzero, 1
        jne main_cycle_trans
        mov belowzero, 0
        call del_symbol
        jmp main_cycle_trans

        skip_deleting_minus2:
        sub len, 1
        call del_symbol
        
        idiv const10
        mov dx, 0

        jmp escape

    toomuch:
        call print_enter
        call print_string C, offset overflow_label
        
        mov ax, 0
        mov len, 0
        mov belowzero, 0

        jmp main_cycle

    to_end:
        cmp belowzero, 1
        je make_rev
        ret
        make_rev:
            not ax
            add ax, 1
    ret
endp

start:
mov ax, @data
mov ds, ax

read_two_numbers:
    call read_int16
    mov bx, ax
    call print_string C, offset slash

    call read_int16

    cmp ax, 0d
    jne next2
    
    call print_enter
    call print_string C, offset division_error_label
    jmp read_two_numbers

next2:
    mov cx, ax ; swap(ax, bx)
    mov ax, bx
    mov bx, cx
    ;call print_uint16 C, ax
    mov dx, 0
    test ax, mask_int16
    je continue3
    neg ax
    not dx
    not ax
    add ax, 1
    continue3:
    idiv bx

    test dx, mask_int16
    je continue4
    test bx, mask_int16
    je go_sub
    add ax, 1
    sub dx, bx
    jmp continue4
    go_sub:
    sub ax, 1
    add dx, bx

    continue4:
    call print_string C, offset equal
    call print_int16 C, ax
    call print_enter
    call print_string C, offset rem
    call print_int16 C, dx
mov ah, 4ch
int 21h

end start