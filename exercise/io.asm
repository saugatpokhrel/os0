; bootloader.asm
; A simple bootloader that prints a welcome message.
; Assemble with: nasm -f bin bootloader.asm -o bootloader
; This code is for educational purposes (exercise 7.5.1 from Operating Systems: From 0 to 1).

[org 0x7c00]
bits 16

;-------------------------------------
; Global variable: current cursor offset (in bytes)
;-------------------------------------
cursor_offset dw 0

;-------------------------------------
; Data: null-terminated message string
;-------------------------------------
msg db 'Welcome to My Operating System!', 0

;------------------------------------------------------------------------------
; start: Bootloader entry point.
;------------------------------------------------------------------------------
start:
    cli                   ; Disable interrupts.
    xor ax, ax
    mov ds, ax            ; Set DS = 0.
    mov es, ax            ; Set ES = 0.

    ; Initialize cursor offset to 0 (top-left of screen).
    mov word [cursor_offset], 0
    ; Update the hardware cursor (set to cell 0).
    call UpdateHWCursor

    ; Print the welcome message.
    mov si, msg
    call Print

hang:
    jmp hang              ; Infinite loop.

;------------------------------------------------------------------------------
; UpdateHWCursor:
;   Reads the global [cursor_offset], converts it to a text cell index 
;   (each cell is 2 bytes), and writes the value to the VGA control registers.
;------------------------------------------------------------------------------
UpdateHWCursor:
    push ax
    push bx
    mov ax, [cursor_offset]
    shr ax, 1             ; Convert byte offset to cell index.
    mov bx, ax            ; Save cell index in BX.
    ; Set high byte of cursor position.
    mov dx, 0x3D4
    mov al, 0x0E
    out dx, al
    mov dx, 0x3D5
    mov al, bh           ; High byte of BX.
    out dx, al
    ; Set low byte of cursor position.
    mov dx, 0x3D4
    mov al, 0x0F
    out dx, al
    mov dx, 0x3D5
    mov al, bl           ; Low byte of BX.
    out dx, al
    pop bx
    pop ax
    ret

;------------------------------------------------------------------------------
; PutChar:
;   Writes the character in AL to video memory at the location given by 
;   [cursor_offset] using a fixed attribute (0x07: white on black). Then 
;   it increments the offset and updates the hardware cursor.
;------------------------------------------------------------------------------
PutChar:
    push ax
    push bx
    push di
    ; Load current cursor offset into DI.
    mov ax, [cursor_offset]
    mov di, ax
    ; Set video segment to B800h (text-mode video memory).
    mov ax, 0xB800
    mov es, ax
    ; Form a word: low byte = character (in AL), high byte = attribute 0x07.
    mov ah, 0x07
    stosw                ; Store AX at ES:DI and increment DI by 2.
    ; Increment cursor offset by 2 bytes (one text cell).
    mov ax, [cursor_offset]
    add ax, 2
    mov [cursor_offset], ax
    ; Update the hardware cursor.
    call UpdateHWCursor
    pop di
    pop bx
    pop ax
    ret

;------------------------------------------------------------------------------
; Print:
;   Prints a null-terminated string pointed to by DS:SI by calling PutChar
;   for each character.
;------------------------------------------------------------------------------
Print:
    pusha
.print_loop:
    lodsb               ; Load byte at DS:SI into AL; SI is incremented.
    cmp al, 0
    je .print_done
    call PutChar
    jmp .print_loop
.print_done:
    popa
    ret

;------------------------------------------------------------------------------
; Boot sector padding and signature.
;------------------------------------------------------------------------------
times 510 - ($ - $$) db 0
dw 0xAA55
