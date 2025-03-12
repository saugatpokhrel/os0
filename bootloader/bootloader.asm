;****************
;A Simple Bootloader
;****************
;This bootloader is designed to be loaded by a BIOS and then to load a kernel from the disk.

org 0x7c00
bits 16
start:
    jmp boot

;; Constants
msg db "Welcome to My Operating System by Saugat Pokhrel!", 0ah, 0dh, 0h, 0

boot:
    cli         ; Disable interrupts
    cld         ; All that we need to init

    call PrintMessage  ; Print the welcome message before loading the kernel

    mov ax, 0x50       ; Set the buffer
    mov es, ax
    xor bx, bx

    mov al, 2          ; Read 2 sectors 
    mov cl, 2          ; Sector to read 
    mov dh, 0
    mov dl, 0

    mov ah, 0x02
    int 0x13           ; BIOS interrupt to read sectors
    jmp 0x50:0x0       ; Jump to the loaded kernel

    hlt                ; Halt the system

;; Function: PrintMessage
;; Prints the message stored in `msg` to the screen using BIOS interrupt 0x10
PrintMessage:
    mov si, msg        ; Load address of the message
.print_loop:
    lodsb              ; Load next character into AL
    cmp al, 0          ; Check for null terminator
    je .done           ; If null, stop printing
    mov ah, 0x0E       ; BIOS teletype output function
    mov bh, 0x00       ; Page number
    int 0x10           ; Call BIOS interrupt
    jmp .print_loop    ; Repeat for next character
.done:
    ret

;We have to be 512 bytes. Clear the rest of the bytes with 0
times 510-($-$$) db 0
dw 0xAA55 ; Boot signature

;The bootloader is very simple. It just prints a message and then halts the system. 
;The kernel 
;The kernel is the main part of the operating system. It is loaded by the bootloader and is responsible for managing the hardware and providing services to the user. 
;The kernel is written in C and assembly. The C code is compiled to an object file and then linked with the assembly code. 
;The kernel is responsible for initializing the hardware, setting up the memory, and providing services to the user. 

