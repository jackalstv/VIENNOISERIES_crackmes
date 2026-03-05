section .data
    msg_ok:         db "Good Job!", 10
    msg_ok_len:     equ $ - msg_ok

    msg_fail:       db "Bad Password!", 10
    msg_fail_len:   equ $ - msg_fail

    rot_table:      db 3, 1, 4, 1, 5, 2, 6, 5, 3, 5, 1, 7, 3, 2, 4, 6

    SEED_A  equ 0x13572468
    SEED_B  equ 0xFEDCBA98
    SEED_C  equ 0x033345BE

section .bss
    input:  resb 17
    tbuf:   resb 16

section .text
global _start

_start:

    xor     eax, eax
    xor     edi, edi
    lea     rsi, [rel input]
    mov     edx, 17
    syscall

    cmp     eax, 17
    jne     fail
    lea     rsi, [rel input]
    cmp     byte [rsi + 16], 0x0A
    jne     fail

    xor     r15d, r15d
    mov     eax, 101
    xor     edi, edi
    xor     esi, esi
    xor     edx, edx
    xor     r10d, r10d
    syscall
    sets    r15b

    rdtsc
    shl     rdx, 32
    or      rax, rdx
    mov     r13, rax

    lea     rsi, [rel input]
    lea     rdi, [rel tbuf]
    lea     r8,  [rel rot_table]
    xor     ecx, ecx

transform_loop:
    cmp     ecx, 16
    jge     after_transform

    movzx   eax, byte [rsi + rcx]
    lea     ebx, [rcx + 0x37]
    xor     al, bl

    movzx   edx, byte [r8 + rcx]
    push    rcx
    mov     cl, dl
    rol     al, cl
    pop     rcx

    mov     byte [rdi + rcx], al
    inc     ecx
    jmp     transform_loop

after_transform:

    rdtsc
    shl     rdx, 32
    or      rax, rdx
    sub     rax, r13
    cmp     rax, 10000000
    jbe     timing_ok
    or      r15b, 0x02

timing_ok:

    lea     rsi, [rel tbuf]
    xor     ebx, ebx
    xor     ecx, ecx

cksum_a_loop:
    cmp     ecx, 8
    jge     cksum_b_init
    rol     ebx, 5
    movzx   eax, byte [rsi + rcx]
    add     ebx, eax
    inc     ecx
    jmp     cksum_a_loop

cksum_b_init:

    xor     edx, edx

cksum_b_loop:
    cmp     ecx, 16
    jge     combine
    ror     edx, 3
    movzx   eax, byte [rsi + rcx]
    xor     edx, eax
    inc     ecx
    jmp     cksum_b_loop

combine:

    ror     edx, 7
    xor     ebx, edx

    mov     eax, ebx
    not     eax
    and     eax, ebx
    jnz     fake_win

    test    r15b, r15b
    jz      compare
    xor     ebx, 0xDEADBEEF

compare:

    mov     eax, SEED_A
    xor     eax, SEED_B
    xor     eax, SEED_C

    cmp     ebx, eax
    jne     fail

success:
    mov     eax, 1
    mov     edi, 1
    lea     rsi, [rel msg_ok]
    mov     edx, msg_ok_len
    syscall
    mov     eax, 60
    xor     edi, edi
    syscall

fake_win:
    mov     eax, 1
    mov     edi, 1
    lea     rsi, [rel msg_ok]
    mov     edx, msg_ok_len
    syscall
    mov     eax, 60
    mov     edi, 1
    syscall

fail:
    mov     eax, 1
    mov     edi, 1
    lea     rsi, [rel msg_fail]
    mov     edx, msg_fail_len
    syscall
    mov     eax, 60
    mov     edi, 1
    syscall