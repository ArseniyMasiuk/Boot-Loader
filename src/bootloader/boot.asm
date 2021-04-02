;
; A boot sector that prints a string using our function.
;
org 0x7c00 ; Tell the assembler where this code will be loaded
bits 16


%define ENDL 0x0D, 0x0A

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

    ; setup data segments
    mov ax, 0           ; can't set ds/es directly
    mov ds, ax
    mov es, ax
    
    ; setup stack
    mov ss, ax
    mov sp, 0x7C00              ; stack grows downwards from where we are loaded in memory

    ; some BIOSes might start us at 07C0:0000 instead of 0000:7C00, make sure we are in the
    ; expected location
    push es
    push word .after
    retf

.after:

    ; read something from floppy disk
    ; BIOS should set DL to drive number
    mov [ebr_drive_number], dl

    ; show loading message
    mov si, msg_loading
    call print_string


	;;reseting the disk system
    ; read drive parameters (sectors per track and head count),
    ; instead of relying on data on formatted disk
    push es
    mov ah, 08h
    int 13h
    jc .floppy_error
    pop es


	;mov dx, 0xfdfd
	;call print_hex
	;mov si, goodbyeM
	;call print_string
	
	mov si, helloM
	call print_string

	call reboot

	jmp $ ; Hang


.floppy_error:
	mov si, floppy_error
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

floppy_error: 				db 'Disk error.',ENDL, 0
helloM: 				db 'hello world!',ENDL, 0
msg_loading:            db 'Loading...',ENDL, 0
reboot_message: 		db 'Press any key to reboot',ENDL, 0
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
