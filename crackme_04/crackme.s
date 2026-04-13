
section .data

msg_banner:     db "=== Le Crackme du Patissier ===", 10
msg_banner_len  equ $ - msg_banner

msg_prompt:     db "Entrez la recette secrete (16 ingredients) : "
msg_prompt_len  equ $ - msg_prompt

msg_len_err:    db "Trop de levure dans ta pate...", 10
msg_len_err_len equ $ - msg_len_err

; deux messages d'echec qui alternent selon rdtsc
msg_fail_a:     db "T'as brule la creme patissiere, recommence.", 10
msg_fail_a_len  equ $ - msg_fail_a

msg_fail_b:     db "Meme mon stagiaire fait de meilleurs macarons.", 10
msg_fail_b_len  equ $ - msg_fail_b

msg_fake:       db "Joli essai, mais les croissants ne se font pas en trichant.", 10
msg_fake_len    equ $ - msg_fake

msg_ok:         db "Good Job!", 10
msg_ok_len      equ $ - msg_ok

msg_fail:       db "Bad Password!", 10
msg_fail_len    equ $ - msg_fail

rot_table:  db 2, 5, 1, 7, 3, 6, 4, 2, 5, 1, 7, 3, 6, 4, 2, 5

SEED_A  equ 0xC4FEC4FE
SEED_B  equ 0xEC141EC1
SEED_C  equ 0xF033CCB2

section .bss
    input:  resb 17
    tbuf:   resb 16

section .text
global _start

_start:
    ; banniere
    mov eax, 1
    mov edi, 1
    lea rsi, [rel msg_banner]
    mov edx, msg_banner_len
    syscall

    ; prompt
    mov eax, 1
    mov edi, 1
    lea rsi, [rel msg_prompt]
    mov edx, msg_prompt_len
    syscall

    ; lecture stdin
    xor eax, eax
    xor edi, edi
    lea rsi, [rel input]
    mov edx, 17
    syscall

    ; verification longueur exacte (16 chars + newline)
    cmp eax, 17
    jne .bad_len
    lea rsi, [rel input]
    cmp byte [rsi + 16], 0x0A
    jne .bad_len

    ; anti-debug ptrace
    xor r15d, r15d
    mov eax, 101
    xor edi, edi
    xor esi, esi
    xor edx, edx
    xor r10d, r10d
    syscall
    sets r15b

    ; timestamp debut
    rdtsc
    shl rdx, 32
    or  rax, rdx
    mov r13, rax

    ; transformation : xor + rol sur chaque byte
    lea rsi, [rel input]
    lea rdi, [rel tbuf]
    lea r8,  [rel rot_table]
    xor ecx, ecx

.loop:
    cmp ecx, 16
    jge .done_transform

    movzx eax, byte [rsi + rcx]
    mov   ebx, ecx
    imul  ebx, 3
    add   ebx, 0x21
    and   ebx, 0xFF
    xor   al, bl

    movzx edx, byte [r8 + rcx]
    push  rcx
    mov   cl, dl
    rol   al, cl
    pop   rcx

    mov byte [rdi + rcx], al
    inc ecx
    jmp .loop

.done_transform:
    ; check timing
    rdtsc
    shl rdx, 32
    or  rax, rdx
    sub rax, r13
    cmp rax, 10000000
    jbe .cksum
    or  r15b, 0x02

.cksum:
    ; checksum partie A (bytes 0-7)
    lea rsi, [rel tbuf]
    xor ebx, ebx
    xor ecx, ecx

.ck_a:
    cmp ecx, 8
    jge .ck_b_init
    rol ebx, 5
    movzx eax, byte [rsi + rcx]
    add ebx, eax
    inc ecx
    jmp .ck_a

.ck_b_init:
    xor edx, edx

    ; checksum partie B (bytes 8-15)
.ck_b:
    cmp ecx, 16
    jge .combine
    ror edx, 3
    movzx eax, byte [rsi + rcx]
    xor edx, eax
    inc ecx
    jmp .ck_b

.combine:
    ror edx, 7
    xor ebx, edx

    ; piege anti-patch : ~x & x vaut toujours 0
    mov eax, ebx
    not eax
    and eax, ebx
    jnz .fake_win

    ; si debuggeur detecte, on corrompt silencieusement
    test r15b, r15b
    jz   .check
    xor  ebx, 0xDEADBEEF

.check:
    mov eax, SEED_A
    xor eax, SEED_B
    xor eax, SEED_C
    cmp ebx, eax
    jne .fail

.success:
    mov eax, 1
    mov edi, 1
    lea rsi, [rel msg_ok]
    mov edx, msg_ok_len
    syscall
    mov eax, 60
    xor edi, edi
    syscall

.fake_win:
    mov eax, 1
    mov edi, 1
    lea rsi, [rel msg_fake]
    mov edx, msg_fake_len
    syscall
    mov eax, 1
    mov edi, 1
    lea rsi, [rel msg_fail]
    mov edx, msg_fail_len
    syscall
    mov eax, 60
    mov edi, 1
    syscall

.bad_len:
    mov eax, 1
    mov edi, 1
    lea rsi, [rel msg_len_err]
    mov edx, msg_len_err_len
    syscall
    jmp .print_fail

.fail:
    ; message qui alterne entre les deux selon rdtsc
    rdtsc
    and eax, 0x01
    jnz .msg_b

    mov eax, 1
    mov edi, 1
    lea rsi, [rel msg_fail_a]
    mov edx, msg_fail_a_len
    syscall
    jmp .print_fail

.msg_b:
    mov eax, 1
    mov edi, 1
    lea rsi, [rel msg_fail_b]
    mov edx, msg_fail_b_len
    syscall

.print_fail:
    mov eax, 1
    mov edi, 1
    lea rsi, [rel msg_fail]
    mov edx, msg_fail_len
    syscall
    mov eax, 60
    mov edi, 1
    syscall