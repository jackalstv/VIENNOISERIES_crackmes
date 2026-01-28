section .data

PASSWORD_LEN      equ 16
EXPECTED_CHECKSUM equ 0x769FC312
FIRST_CHAR        equ 0x62

msg_ok:       db "good job !", 10
msg_ok_len:   equ $ - msg_ok

msg_fail:     db "Wrong password !", 10
msg_fail_len: equ $ - msg_fail

msg_prompt:   db "Password: "
msg_prompt_len: equ $ - msg_prompt

section .bss
    input: resb 17

section .text
    global _start

_start:
    mov     rax, 1
    mov     rdi, 1
    lea     rsi, [rel msg_prompt]
    mov     rdx, msg_prompt_len
    syscall

    xor     rax, rax
    xor     rdi, rdi
    lea     rsi, [rel input]
    mov     rdx, 17
    syscall

    cmp     rax, 17
    jne     fail

    lea     rsi, [rel input]
    movzx   eax, byte [rsi]
    cmp     al, FIRST_CHAR
    jne     fail

    xor     ebx, ebx
    xor     ecx, ecx

.check_loop:
    rol     ebx, 5
    movzx   eax, byte [rsi + rcx]
    add     ebx, eax
    inc     ecx
    cmp     ecx, PASSWORD_LEN
    jl      .check_loop

    cmp     ebx, EXPECTED_CHECKSUM
    jne     fail

    mov     rax, 1
    mov     rdi, 1
    lea     rsi, [rel msg_ok]
    mov     rdx, msg_ok_len
    syscall

    mov     rax, 60
    xor     rdi, rdi
    syscall

fail:
    mov     rax, 1
    mov     rdi, 1
    lea     rsi, [rel msg_fail]
    mov     rdx, msg_fail_len
    syscall

    mov     rax, 60
    mov     rdi, 1
    syscall
