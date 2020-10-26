; aes 
%macro key_expand 1
    aeskeygenassist xmm1, xmm0, %1
    pshufd xmm1, xmm1, 0b11111111
    shufps xmm2, xmm0, 0b00010000
    pxor xmm0, xmm2
    shufps xmm2, xmm0, 0b10001100
    pxor xmm0, xmm2
    pxor xmm0, xmm1
%endmacro

; sys_open
%define O_RDONLY 0
%define O_WRONLY 1
%define O_RDWR   2

; sys_mmap
%define PROT_READ     0x01
%define PROT_WRITE    0x02
%define PROT_EXEC     0x04
%define MAP_SHARED    0x01
%define MAP_PRIVATE   0x02
%define MAP_ANONYMOUS 0x20

