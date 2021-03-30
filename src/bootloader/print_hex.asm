print_hex:
    pusha
    mov si, PREFIX
    call print_string

next_character:
    mov bx, dx
    and bx, 0xf000
    shr bx, 4
    add bh, 0x30
    cmp bh, 0x39
    jg add_7

print_character_hex:
   mov al, bh
   mov ah, 0x0e
   int 0x10
   shl dx, 4
   or dx, dx
   jnz next_character
   popa
   ret

add_7:
   add bh, 0x7
   jmp print_character_hex

PREFIX:
   db '0x', 0