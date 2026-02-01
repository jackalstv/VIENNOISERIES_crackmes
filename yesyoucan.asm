section .data
    prompt:         db "Mot de passe: ", 0
    prompt_len:     equ $ - prompt

    success_msg:    db "Bon Travail !", 10, 0
    success_len:    equ $ - success_msg

    fail_msg:       db "Mauvais Mot De Passe !", 10, 0
    fail_len:       equ $ - fail_msg

    permutation:    db 7, 2, 13, 0, 9, 4, 15, 1, 11, 6, 3, 14, 5, 10, 8, 12

    FIRST_CHAR:     equ 'b'
    EXPECTED_SUM:   equ  0x72b1de0a    

section .bss
    input:          resb 18

section .text
    global _start

_start:
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel prompt]
    mov rdx, prompt_len
    syscall

    xor rax, rax
    xor rdi, rdi
    lea rsi, [rel input]
    mov rdx, 17
    syscall

    cmp rax, 17
    jne .fail

    lea rsi, [rel input]
    movzx eax, byte [rsi]
    cmp al, FIRST_CHAR
    jne .fail

    xor r8d, r8d
    xor ecx, ecx
    lea rdi, [rel permutation]

.loop:
    cmp ecx, 16
    jge .check

    movzx eax, byte [rdi + rcx]
    movzx eax, byte [rsi + rax]

    rol r8d, 5
    add r8d, eax

    inc ecx
    jmp .loop

.check:
    cmp r8d, EXPECTED_SUM
    jne .fail

.success:
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel success_msg]
    mov rdx, success_len
    syscall

    mov rax, 60
    xor edi, edi
    syscall

.fail:
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel fail_msg]
    mov rdx, fail_len
    syscall

    mov rax, 60
    mov edi, 1
    syscall
