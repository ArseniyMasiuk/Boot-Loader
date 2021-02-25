;
; A boot sector that prints a string using our function.
;
[org 0x7c00] ; Tell the assembler where this code will be loaded

mov si, helloM
call print_string

;mov si, goodbyeM
;call print_string

jmp $ ; Hang


%include "print_string.asm"

helloM db 'hello world!', 0
goodbyeM db 'Goodbye', 0 

; Padding and magic number.
times 510 -( $ - $$ ) db 0
dw 0xaa55
