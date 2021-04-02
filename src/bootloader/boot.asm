;
; A boot sector that prints a string using our function.
;
org 0x7c00 ; Tell the assembler where this code will be loaded
bits 16

;
; FAT12 header
; 

jmp short start
nop
;boot parameter block
bdb_oem:                    db 'MSWIN4.1'           ; 8 bytes
bdb_bytes_per_sector:       dw 512
bdb_sectors_per_cluster:    db 1
bdb_reserved_sectors:       dw 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 0E0h
bdb_total_sectors:          dw 2880                 ; 2880 * 512 = 1.44MB
bdb_media_descriptor_type:  db 0F0h                 ; F0 = 3.5" floppy disk
bdb_sectors_per_fat:        dw 9                    ; 9 sectors/fat
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0

; extended boot record (extended boot parameter block)
ebr_drive_number:           db 0                    ; 0x00 floppy, 0x80 hdd, useless
ebr_reserved:               db 0                    ; reserved
ebr_signature:              db 29h
ebr_volume_id:              db 12h, 34h, 56h, 78h   ; serial number, value doesn't matter
ebr_volume_label:           db 'Pet-OS     '        ; 11 bytes, padded with spaces
ebr_system_id:              db 'FAT12   '           ; 8 bytes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

start:

	mov si, helloM
	call print_string
	;call reboot

	;;;;save booted drive;;;;;;;setup data segments
	cli 						;turn off interrupts
	mov [ebr_drive_number], dl 	;save what drive we booted from (should be 0x0)
	mov ax, cx					;CS = 0x0, since that's where boot sector is (0x07c00)
	mov  ds, ax          		;DS = CS = 0x0
	mov  es, ax          		;ES = CS = 0x0
	mov  ss, ax          		;SS = CS = 0x0
	mov  sp, 0x7c00      		;Stack grows down from offset 0x7C00 toward 0x0000.
	sti                  		;Enable interrupts
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;reseting the disk system
	mov dl, [ebr_drive_number]	;drive to reset
	xor ax, ax					;subfnction 0
	int 0x13					;call interrupt 0x13 
	adc dx, 0
	call print_hex

	jc boot_failure 			;display error message if carry set (error)

	;mov dx, 0xfdfd
	;call print_hex
	;mov si, goodbyeM
	;call print_string
	
	mov si, helloM
	call print_string

	call reboot

	jmp $ ; Hang





boot_failure:
	mov si, boot_f
	call print_string
	ret

reboot:
	mov si, reboot_message
	call print_string
	xor ax, ax
	int 0x16
	db 0xea
	dw 0x0000
	dw 0xffff

%include "src/bootloader/print_string.asm"
%include "src/bootloader/print_hex.asm"

boot_f: db 'Disk error.', 0
helloM: db 'hello world!', 0
reboot_message: db 'Press any key to reboot', 0
;goodbyeM: db 'Goodbye', 0 

; Padding and magic number.
times 510 -( $ - $$ ) db 0
dw 0xaa55


;je target ; jump if equal ( i.e. x == y)
;jne target ; jump if not equal ( i.e. x != y)
;jl target ; jump if less than ( i.e. x < y)
;jle target ; jump if less than or equal ( i.e. x <= y)
;jg target ; jump if greater than ( i.e. x > y)
;jge target ; jump if greater than or equal ( i.e. x >= y)
