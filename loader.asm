BITS 64
    org      0x00400000                

%include 'loader.inc'               
%include 'control.inc'

ehdr:
    db 0x7F, "ELF", 2, 1, 1, 0       ; e_ident
    times 8 db 0                     ; reservado
    dw 2                             ; e_type       
    dw 0x3e                          ; e_machine    
    dd 1                             ; e_version    
    dq _start                        ; e_entry      
    dq phdr1 - $$                    ; e_phoff       
    dq 0                             ; e_shoff       
    dd 0                             ; e_flags       
    dw ehdrsize                      ; e_ehsize    
    dw phdrsize                      ; e_phentsize  
    dw 2                             ; e_phnum   
    dw 0                             ; e_shentsize
    dw 0                             ; e_shnum       
    dw 0                             ; e_shstrndx
ehdrsize equ $ - ehdr

phdr1:
    dd 1                             ; p_type     loadable 
    dd 7                             ; p_flags    rwx
    dq 0                             ; p_offset
    dq $$                            ; p_vaddr    
    dq $$                            ; p_paddr     
    dq filesize                      ; p_filesz
    dq filesize                      ; p_memsz
    dq 0                             ; p_align   
phdrsize equ $ - phdr1

phdr2:
    dd 1                             ; p_type     loadable 
    dd 7                             ; p_flags    rwx
    dq 0                             ; p_offset
    dq HELPERSLOC                    ; p_vaddr    
    dq $$                            ; p_paddr     
    dq filesiz                       ; p_filesz
    dq filesize                      ; p_memsz
    dq 0                             ; p_align   

_helper:
    %include 'key.inc'

    movups xmm5, [key]
    movups xmm0, xmm5

    pxor xmm2, xmm2

    key_expand 1 
    aesimc xmm6, xmm0
    key_expand 2
    aesimc xmm7, xmm0
    key_expand 4 
    aesimc xmm8, xmm0
    key_expand 8 
    aesimc xmm9, xmm0
    key_expand 16
    aesimc xmm10, xmm0
    key_expand 32
    aesimc xmm11, xmm0
    key_expand 64
    aesimc xmm12, xmm0
    key_expand 128
    aesimc xmm13, xmm0
    key_expand 27
    aesimc xmm14, xmm0
    key_expand 54
    movups xmm15, xmm0

    mov r13, input
    mov r11, ehdr
decrypt:
    movups xmm0, [r13]

    pxor xmm0, xmm15
    aesdec xmm0, xmm14
    aesdec xmm0, xmm13
    aesdec xmm0, xmm12
    aesdec xmm0, xmm11
    aesdec xmm0, xmm10
    aesdec xmm0, xmm9
    aesdec xmm0, xmm8
    aesdec xmm0, xmm7
    aesdec xmm0, xmm6
    aesdeclast xmm0, xmm5

    movaps [r11], xmm0

    cmp r11, ehdr
    je checker   
 
ok:
    add r13, 16
    add r11, 16
    cmp r13, fin
    jl decrypt

    mov rax, ENTRYPOINT
    jmp rax

checker:
    cmp qword [r11 + 8], 0
    je ok

    mov rax, 60
    mov rdi, 1
    syscall

_start:
    mov r13, HELPERSLOC + (_helper - ehdr)
    jmp r13 

input:
    incbin ENC_FILE
fin:
filesize equ $-$$
