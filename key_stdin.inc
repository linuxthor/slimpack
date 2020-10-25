
   ;
   ; read password from stdin   

    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, len
    syscall

    mov rax, 0 
    mov rdi, 0
    mov rsi, key
    mov rdx, 16
    syscall     

    jmp cont

    prompt db 'Enter password:',0x0d,0x0a,0
    len equ $-prompt

    key resb 32

cont:
    
