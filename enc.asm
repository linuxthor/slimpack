BITS 64
org 0x0040000

; sys_open
%define O_MODES   0x42              ; O_RDWR|O_CREAT

%macro key_expand 2 
    aeskeygenassist xmm1, xmm0, %1
    pshufd xmm1, xmm1, 0b11111111
    shufps xmm2, xmm0, 0b00010000
    pxor   xmm0, xmm2
    shufps xmm2, xmm0, 0b10001100
    pxor   xmm0, xmm2
    pxor   xmm0, xmm1
    movups %2, xmm0 
%endmacro

ehdr:
    db 0x7F, "ELF", 2, 1, 1, 0       ; e_ident
    times 8 db 0                     ; reservado
    dw 2                             ; e_type       
    dw 0x3e                          ; e_machine    
    dd 1                             ; e_version    
    dq _start                        ; e_entry      
    dq phdr - $$                     ; e_phoff       
    dq 0                             ; e_shoff       
    dd 0                             ; e_flags       
    dw ehdrsize                      ; e_ehsize    
    dw phdrsize                      ; e_phentsize  
    dw 1                             ; e_phnum   
    dw 0                             ; e_shentsize
    dw 0                             ; e_shnum       
    dw 0                             ; e_shstrndx
ehdrsize equ $ - ehdr

phdr:
    dd 1                             ; p_type     loadable 
    dd 7                             ; p_flags    rwx
    dq 0                             ; p_offset
    dq $$                            ; p_vaddr    
    dq $$                            ; p_paddr     
    dq filesize                      ; p_filesz
    dq filesize                      ; p_memsz
    dq 0                             ; p_align   
phdrsize equ $ - phdr

_start:
    mov rax, 2                    ; sys_open
    mov rdi, filenm
    mov rsi, O_MODES
    mov rdx, 755o
    syscall

    cmp rax, 3
    jl _exit

    mov [fd], rax

    %include 'key.inc' 

    movups xmm0, [key]
    movups xmm5, xmm0
   
    pxor xmm2, xmm2

    key_expand 1,   xmm6
    key_expand 2,   xmm7
    key_expand 4,   xmm8
    key_expand 8,   xmm9
    key_expand 16,  xmm10 
    key_expand 32,  xmm11
    key_expand 64,  xmm12
    key_expand 128, xmm13
    key_expand 27,  xmm14
    key_expand 54,  xmm15

    mov r13, input
encrypt: 
    movups xmm0, [r13]
    
    pxor   xmm0,     xmm5
    aesenc xmm0,     xmm6
    aesenc xmm0,     xmm7
    aesenc xmm0,     xmm8
    aesenc xmm0,     xmm9
    aesenc xmm0,     xmm10
    aesenc xmm0,     xmm11
    aesenc xmm0,     xmm12
    aesenc xmm0,     xmm13
    aesenc xmm0,     xmm14
    aesenclast xmm0,xmm15

     movups [buf], xmm0

     mov rax, 1
     mov rdi, [fd]
     mov rsi, buf
     mov rdx, 16
     syscall

     add r13, 16
     cmp r13, fin
     jl encrypt 

_exit:
     mov rax, 60
     mov rdi, 0
     syscall

     filenm db './200.enc',0

     buf resb 16
     fd resq  1

     input incbin './input'    
fin:
filesize equ $-$$ 
