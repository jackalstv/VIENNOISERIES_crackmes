; crack_oups.s - patch le binaire oups
; usage: ./crack_oups <binaire>
; remplace GOOD_FLAG_16CHAR par CR4CK1NG5N0TCR1M

section .data
    search_seq:  db "GOOD_FLAG_16CHAR"
    search_len:  equ $ - search_seq

    patch_seq:   db "CR4CK1NG5N0TCR1M"

    msg_ok:          db "Patch applied! New flag: CR4CK1NG5N0TCR1M", 10
    msg_ok_len:      equ $ - msg_ok
    msg_err_args:    db "Usage: ./crack_oups <crackme_binary>", 10
    msg_err_args_len: equ $ - msg_err_args
    msg_err_open:    db "Error: cannot open file", 10
    msg_err_open_len: equ $ - msg_err_open
    msg_err_read:    db "Error: cannot read file", 10
    msg_err_read_len: equ $ - msg_err_read
    msg_err_write:   db "Error: cannot write file", 10
    msg_err_write_len: equ $ - msg_err_write
    msg_err_found:   db "Error: pattern not found", 10
    msg_err_found_len: equ $ - msg_err_found

section .bss
    buf: resb 65536
    fd:  resq 1

section .text
global _start

_start:
    ; verif argc >= 2
    mov rax, [rsp]
    cmp rax, 2
    jl  err_args

    ; open(argv[1], O_RDWR)
    mov rax, 2
    mov rdi, [rsp + 16]
    mov rsi, 2
    xor rdx, rdx
    syscall
    test rax, rax
    js   err_open
    mov  [rel fd], rax

    ; read(fd, buf, 65536)
    mov rdi, rax
    mov rax, 0
    lea rsi, [rel buf]
    mov rdx, 65536
    syscall
    test rax, rax
    jle  err_read
    mov  r14, rax

    ; cherche la flag dans le buffer
    lea rsi, [rel buf]
    lea r8,  [rel search_seq]
    xor rcx, rcx

search_loop:
    mov rax, r14
    sub rax, search_len
    cmp rcx, rax
    jg  err_not_found
    mov rax, qword [rsi + rcx]
    cmp rax, qword [r8]
    jne search_next
    mov rax, qword [rsi + rcx + 8]
    cmp rax, qword [r8 + 8]
    jne search_next
    jmp found

search_next:
    inc rcx
    jmp search_loop

found:
    ; patch les 16 bytes
    lea r9, [rel patch_seq]
    mov rax, qword [r9]
    mov qword [rsi + rcx],     rax
    mov rax, qword [r9 + 8]
    mov qword [rsi + rcx + 8], rax

    ; lseek(fd, 0, SEEK_SET)
    mov rax, 8
    mov rdi, [rel fd]
    xor rsi, rsi
    xor rdx, rdx
    syscall

    ; rewrite le fichier
    mov rax, 1
    mov rdi, [rel fd]
    lea rsi, [rel buf]
    mov rdx, r14
    syscall
    test rax, rax
    jle  err_write

    ; close(fd)
    mov rax, 3
    mov rdi, [rel fd]
    syscall

    ; succes
    mov rax, 1
    mov edi, 1
    lea rsi, [rel msg_ok]
    mov edx, msg_ok_len
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall

err_args:
    mov rax, 1
    mov edi, 2
    lea rsi, [rel msg_err_args]
    mov edx, msg_err_args_len
    syscall
    jmp exit_fail

err_open:
    mov rax, 1
    mov edi, 2
    lea rsi, [rel msg_err_open]
    mov edx, msg_err_open_len
    syscall
    jmp exit_fail

err_read:
    mov rax, 1
    mov edi, 2
    lea rsi, [rel msg_err_read]
    mov edx, msg_err_read_len
    syscall
    jmp exit_fail

err_write:
    mov rax, 1
    mov edi, 2
    lea rsi, [rel msg_err_write]
    mov edx, msg_err_write_len
    syscall
    jmp exit_fail

err_not_found:
    mov rax, 1
    mov edi, 2
    lea rsi, [rel msg_err_found]
    mov edx, msg_err_found_len
    syscall

exit_fail:
    mov rax, 60
    mov rdi, 1
    syscall
