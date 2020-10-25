    %define O_RDONLY 0

    ; read key from some offset in a file

    mov rax, 2                 ; sys_open
    mov rdi, key_file
    mov rsi, O_RDONLY
    mov rdx, 0
    syscall 

    mov [kfd], rax

    mov rax, 8                 ; sys_lseek
    mov rdi, [kfd]
    mov rsi, [key_offset]   ;0
    mov rdx, 0                 ; SEEK_SET / set to exact offset
    syscall

    mov rax, 0
    mov rdi, [kfd]
    mov rsi, key
    mov rdx, 16
    syscall

    jmp cont

    kfd resq 1
    key resb 16

    %include 'key_file_vars.inc'

cont: 
