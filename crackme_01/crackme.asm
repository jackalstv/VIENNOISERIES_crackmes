section .data
    msg_ok:     db "Good Job!", 10
    msg_ok_len: equ $ - msg_ok

    msg_fail:     db "Bad Password!", 10
    msg_fail_len: equ $ - msg_fail

    MOITIE_A equ 0x2ec8e827
    MOITIE_B equ 0xc528d075

section .bss
    input:  resb 17
    tbuf:   resb 16

section .text
    global _start

_start:
    ; [1] Vérification de longueur
    xor eax, eax
    xor edi, edi
    lea rsi, [rel input]
    mov edx, 17
    syscall

    cmp eax, 17
    jne .fail

    lea rsi, [rel input]
    cmp byte [rsi + 16], 0x0A
    jne .fail

    ; [2] Anti-debug ptrace
    mov eax, 101
    xor edi, edi
    xor esi, esi
    xor edx, edx
    xor r10d, r10d
    syscall
    sets r15b

    ; [3] Transform XOR+ROL8 sur chaque caractère
    lea rsi, [rel input]
    lea rdi, [rel tbuf]
    xor ecx, ecx

.transform_loop:
    cmp ecx, 16
    jge .checksum_start

    movzx eax, byte [rsi + rcx]
    xor al, 0x5A
    rol al, 3
    mov byte [rdi + rcx], al

    inc ecx
    jmp .transform_loop

    ; [4] Checksum ROL32+ADD sur tbuf
.checksum_start:
    lea rsi, [rel tbuf]
    xor ebx, ebx
    xor ecx, ecx

.checksum_loop:
    cmp ecx, 16
    jge .anti_debug_taint

    rol ebx, 5
    movzx eax, byte [rsi + rcx]
    add ebx, eax

    inc ecx
    jmp .checksum_loop

    ; [5] Taint silencieux si débogueur détecté
.anti_debug_taint:
    test r15b, r15b
    jz .compare

    xor ebx, 0xCAFEBABE

    ; [6] Comparaison avec constante obfusquée
.compare:
    mov eax, MOITIE_A
    xor eax, MOITIE_B

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

.fail:
    mov eax, 1
    mov edi, 1
    lea rsi, [rel msg_fail]
    mov edx, msg_fail_len
    syscall

    mov eax, 60
    mov edi, 1
    syscall
