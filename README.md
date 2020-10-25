# slimpack

Welcome! Slimpack is a tool that allows for the creation of AES-NI encrypted file loaders from single source code file NASM projects.    

For example:    

```
BITS 64

global _start
_start:

    mov rax, 59           ;  sys_execve
    mov rdi, cmd
    mov [arg], rdi        ;  argv0 cmd name
    mov rbx, av1
    mov [arg+8], rbx
    mov rsi, arg
    mov rdx, 0            ;  envp (null)
    syscall 

    mov rax, 60           ;  sys_exit
    syscall

section .data
    cmd  db  '/bin/echo',0
    av1  db  'hiya mateys',0

section .bss
    arg  resq  8
```

(All being well) slimpack will remove the section definitions and build a binary with .text / .data / .bss all together.     

The file is then encrypted with Intel AES-NI instructions (AES128-ECB "possibly" done correctly - I copied the code from the well commented GAS syntax examples at https://github.com/kmcallister/aesni-examples but have done minimal checks for correctness.. n.b: ECB is a weaker mode but 'good enough' here)     

The loader is then built.. A small stub of code that sets up the process to run in rwx memory (via program header flag) and maps itself an area of rwx memory to work in and do the decryption fetching the key from one of three locations:     

1) From stdin:      

When the loader is run the user is prompted to enter a password of 16 characters on stdin. If this is correct the program executes.      

2) From a file:     

When the loader is run it reads 16 bytes from a chosen offset in some file and uses that as the key.         

3) Hardcoded:    

When the loader is run it reads the key from it's own program memory where it is hardcoded in plaintext.    

Example:    

```
# First set the chosen method in key.inc and configure in it's inc file if required (e.g file location/offset etc)
$ ./rebuild_loader.sh /tmp/input.asm /tmp/build
Removing section attributes from input file
Building input file
Building encrypter
Runing encrypter
Building loader
Done
$ strace /tmp/build

execve("/tmp/build", ["/tmp/build"], 0x7ffdf20285a0 /* 58 vars */) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0) = 0x7fa73f2c2000
open("/etc/ssh/ssh_host_rsa_key.pub", O_RDONLY) = 3
lseek(3, 72, SEEK_SET)                  = 72
read(3, "rTmaPkoitYdtRutk", 16)         = 16
execve("/bin/echo", ["/bin/echo", "hiya mateys"], NULL) = 0
```

Notes: The code is a little rough, especially in the encrypter as this is something of an unfinished project.     
