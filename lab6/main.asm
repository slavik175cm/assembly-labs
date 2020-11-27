.model small
.stack 100h

.data
    const10 dw 10d
    was_button_just_pressed db 0
    is_shift_pressed db 0
    old_int_09h dd 00
    last_button dw 0
    encryption_key db 100 dup(?)
    encryption_key_length dw 0
    encryption_key_iterator dw 0
    scan_table db 1eh, 30h, 2eh, 20h, 12h, 21h, 22h, 23h, 17h, 24h, 25h, 26h, 32h, 31h, 18h, 19h, 10h, 13h, 1fh, 14h, 16h, 2fh, 11h, 2dh, 15h, 2ch 
    scan_table_length dw 26
    msg_no_key db "There is not encryption key$"
    msg_key_is_too_big db "Encryption key is too big$"
    msg_invalid_key db "Encryption key is invalid$"
    char db ?
    return db ?

.code
include my_funcs.asm

set_my_handler proc C near
;uses ax, bx, dx, ds
    mov ax, 3509h
    int 21h
    mov word ptr old_int_09h, bx
    mov word ptr old_int_09h+2, es
    
    push ds
    mov ax, 2509h
    mov dx, @code
    mov ds, dx
    mov dx, offset my_int_09h   
    int 21h
    pop ds
    
    ret
set_my_handler endp
    
set_sys_handler proc C near
;uses ax, bx, dx, ds
    mov ax, 2509h
    mov dx, word ptr old_int_09h
    mov bx, word ptr old_int_09h+2
    mov ds, bx
    int 21h
    pop ds
    
    ret
set_sys_handler endp

get_ASCII_from_scan proc C near
arg scan_code:word, response:word
uses si, bx, dx, cx
    mov cx, scan_table_length
    mov si, 0
    l1:
        mov bx, scan_code
        cmp scan_table[si], bl
        je to_end1
        inc si
        loop l1 
    
    to_end1:
    mov dx, 0
    cmp si, scan_table_length
    je symbol_is_not_a_letter

    mov dx, si
    add dx, 65

    symbol_is_not_a_letter:
    mov bx, response
    mov [bx], dx

    ret

get_ASCII_from_scan endp

encode proc C near
arg symbol:word, shift:word
uses ax 
    mov bx, symbol
    mov ax, [bx]

    add ax, shift
    sub ax, 65
    cmp ax, 90d
    jle continue
    sub ax, 26

    continue:
    mov bx, symbol
    mov [bx], ax
    ret
encode endp


my_int_09h proc
    push ax bx cx dx es ds si di
    cli
    xor ax, ax
    in al, 60h  ; current char in al

    ;call print_uint16 C, ax
    cmp al, 42 ;lshift
    je shift_pressed_trans
    cmp al, 170 ;lshift released
    je shift_pressed_trans
    cmp al, 54 ;rshift
    je shift_pressed_trans
    cmp al, 183 ;rshift released
    je shift_pressed_trans


    cmp was_button_just_pressed, 1
    je procedure_exit_trans

    mov ah, 0
    mov last_button, ax
    call get_ASCII_from_scan C, ax, offset char ; [char] - ascii of current capital letter(al)
    
    cmp char, 0
    je procedure_exit_trans

    mov si, encryption_key_iterator
    inc encryption_key_iterator
    mov cl, encryption_key[si]
    mov ch, 0
    call encode C, offset char, cx ;[char] - encoded symbol , cx - shift

jmp skip1
shift_pressed_trans:
jmp shift_pressed
procedure_exit_trans:
jmp procedure_exit
skip1:

    cmp is_shift_pressed, 1
    je continue2
    call to_lower C, offset char
    continue2:

    call print_char C, word ptr[char] 

    mov bx, encryption_key_length
    cmp encryption_key_iterator, bx
    jne continue1
    mov encryption_key_iterator, 0

    continue1:

    procedure_exit:
    xor was_button_just_pressed, 1
    mov al, 20h
    out 20h, al
    pop di si ds es dx cx bx ax 
    sti
    iret

    shift_pressed:
    xor is_shift_pressed, 1
    xor was_button_just_pressed, 1
    jmp procedure_exit

my_int_09h endp

get_encryption_key proc C near
uses ax, bx, cx, dx, si
    mov dh, 0
    mov dl, es:[80h]
    cmp dx, 0
    je no_key
    cmp dx, 101
    jae key_is_too_big

    sub dx, 1
    mov encryption_key_length, dx
    mov cx, dx
    mov bx, 82h
    mov si, 0
    go:
        mov al, es:[bx]
        mov encryption_key[si], al
        
        mov ah, 0
        call is_letter C, ax, offset return
        cmp return, 0
        je invalid_key


        mov ax, offset encryption_key
        add ax, si
        call to_upper C, ax ; ax - offset encryption_key[si]

        inc bx
        inc si
        loop go
    ;mov encryption_key[si], '$' ;delete
    jmp to_end2

    no_key:
    call print_string C, offset msg_no_key
    jmp exit_program

    key_is_too_big:
    call print_string C, offset msg_key_is_too_big
    jmp exit_program

    invalid_key:
    call print_string C, offset msg_invalid_key
    jmp exit_program

    exit_program:
    mov ah, 4ch
    int 21h

    to_end2:
    ;call print_string C, offset encryption_key
    ret
get_encryption_key endp

is_upper_letter proc C near
arg symbol:word, response:word
uses bx
    mov bx, response
    mov byte ptr [bx], 0
    cmp symbol, 65
    jl to_end6
    cmp symbol, 90
    ja to_end6

    mov byte ptr [bx], 1

    to_end6:
    ret
is_upper_letter endp

is_lower_letter proc C near
arg symbol:word, response:word
uses bx
    mov bx, response
    mov byte ptr [bx], 0
    cmp symbol, 97
    jl to_end7
    cmp symbol, 122
    ja to_end7

    mov byte ptr [bx], 1

    to_end7:
    ret
is_lower_letter endp

to_upper proc C near
arg symbol_offset:word
uses bx
    mov bx, symbol_offset
    
    call is_upper_letter C, word ptr [bx], offset return
    cmp return, 1
    je to_end3
    ;need_change
    sub byte ptr [bx], 32

    to_end3:
    ret
to_upper endp

to_lower proc C near
arg symbol_offset:word
uses bx
    mov bx, symbol_offset

    call is_lower_letter C, word ptr [bx], offset return
    cmp return, 1
    je to_end4

    ;need_change
    add byte ptr[bx], 32

    to_end4:
    ret
to_lower endp

is_letter proc C near
arg symbol:word, response:word
uses ax, bx
    mov bx, response
    mov byte ptr [bx], 0
    mov al, 0

    call is_lower_letter C, symbol, offset return
    mov al, return
    ;or byte ptr [bx], al
    call is_upper_letter C, symbol, offset return
    or al, return
    ;or byte ptr [bx], al
    mov ah, 0
    mov byte ptr[bx], al
    
    ret
is_letter endp

start:
mov ax, @data
mov ds, ax

call get_encryption_key

call set_my_handler

main_cycle:
    cmp last_button, 1
    jne main_cycle

call set_sys_handler

mov ah, 4ch
int 21h

end start