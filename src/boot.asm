[BITS 16]        ; Set the code to 16-bit mode
[ORG 0x7c00]     ; Set the origin (starting address) to 0x7c00, typical for boot loaders

CODE_OFFSET equ 0x8
DATA_OFFSET equ 0x10

KERNEL_LOAD_SEG equ 0x1000
KERNEL_START_ADDR equ 0x100000

start:
    mov si, real_mode_msg
    call print_string

    cli
    mov ax, 0x00  
    mov ds, ax    
    mov es, ax    
    mov ss, ax    
    mov sp, 0x7c00
    sti

; Load kernel
mov si, loading_kernel_msg
call print_string
mov cx, 0xFFFF
delay_loop:
    loop delay_loop

mov bx, KERNEL_LOAD_SEG
mov dh, 0x00
mov dl, 0x80
mov cl, 0x02
mov ch, 0x00
mov ah, 0x02
mov al, 8
int 0x13

jc disk_read_error

mov si, kernel_loaded_msg
call print_string

jmp load_PM  ; Jump to Protected Mode setup

disk_read_error:
    mov si, kernel_failed_msg
    call print_string
    hlt

loading_kernel_msg db "Loading Kernel...", 0
kernel_loaded_msg db "Kernel Loaded!", 0
kernel_failed_msg db "Kernel Load Failed!", 0

real_mode_msg db "Real Mode Active", 0

print_string:
    mov ah, 0x0E
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

load_PM:
    cli
    mov si, gdt_loading_msg
    call print_string

    lgdt [gdt_descriptor]  ; Load the Global Descriptor Table

    mov si, gdt_loaded_msg
    call print_string

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp protected_mode_entry

gdt_loading_msg db "Loading GDT...", 0
gdt_loaded_msg db "GDT Loaded!", 0

; --- GDT Implementation ---
gdt_start:
    dd 0x0
    dd 0x0

    ; Code segment descriptor
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

    ; Data segment descriptor
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start 

[BITS 32]
protected_mode_entry:
    mov ax, DATA_OFFSET
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov ss, ax
    mov gs, ax
    mov ebp, 0x9C00
    mov esp, ebp

    mov si, protected_mode_msg
    call print_string
    hlt

protected_mode_msg db "Protected Mode Active", 0

jmp CODE_OFFSET:KERNEL_START_ADDR

times 510 - ($ - $$) db 0
dw 0xAA55   ; Boot sector signature
