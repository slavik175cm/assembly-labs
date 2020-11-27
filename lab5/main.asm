model small
.stack 100h
.data
n dw 0
i dw 0
j dw 0
k dw 0
dist1 dw 0
dist2 dw 0
array dw 202 dup(?)
space dw 32
const10 dw 10d
.code
include my_funcs.asm


get_index proc C near
arg ii, jj, nn : word
uses ax
    mov ax, ii
    mul byte ptr nn
    add ax, jj
    mov bx, 2d
    mul bx
    mov si, ax
    ret
endp

start:
mov ax, @data
mov ds, ax

call read_uint16 ; response in ax
call print_enter ; DELETE BEFORE SENDING
mov n, ax
mov i, 0
i_loop:
    mov j, 0    
    j_loop:
        call read_uint16
        call get_index C, i, j, n ; index in si
        mov array[si], ax
        call print_char C, space ;DELETE BEFORE SENDING


        inc j
        mov ax, n
        cmp j, ax ; cmp j, n
        jne j_loop

    end_j_loop:
    call print_enter ; DELETE BEFORE SENDING

    inc i
    mov ax, n
    cmp i, ax
    jne i_loop
end_i_loop:


mov k, 0
k_loop1:
    mov i, 0    
    i_loop1:
        mov j, 0
        j_loop1:
            call get_index C, i, k, n
            mov ax, array[si]
            mov dist1, ax
            call get_index C, k, j, n
            mov ax, array[si]
            mov dist2, ax
            call get_index C, i, j, n
            mov ax, dist1
            add ax, dist2
            cmp array[si], ax
            jb continue
            mov array[si], ax
            jmp continue

k_loop1_trans:
jmp k_loop1
i_loop1_trans:
jmp i_loop1
            continue:
            
            inc j
            mov ax, n
            cmp j, ax   
            jne j_loop1
        end_j_loop1:

        inc i
        mov ax, n
        cmp i, ax
        jne i_loop1_trans
    end_i_loop1:

    inc k
    mov ax, n
    cmp k, ax
    jne k_loop1_trans
end_k_loop1:

mov i, 0
i_loop2:
    mov j, 0    
    j_loop2:
        call get_index C, i, j, n ; index in si
        call print_uint16 C, array[si]
        call print_char C, space

        inc j
        mov ax, n
        cmp j, ax
        jne j_loop2

    end_j_loop2:
    call print_enter
    inc i
    mov ax, n
    cmp i, ax

    jne i_loop2
end_i_loop2:

mov ah, 4ch
int 21h

end start 