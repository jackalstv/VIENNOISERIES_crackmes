section .data
    good_msg db "Good Job!", 10, 0
    good_len equ $ - good_msg
    bad_msg db "Bad Password!", 10, 0
    bad_len equ $ - bad_msg

section .bss
    input resb 100

section .text
    global _start

_start:
    mov eax, 3         
    mov ebx, 0         
    mov ecx, input
    mov edx, 100
    int 0x80

    mov esi, input
    
    cmp byte [esi], 'C'
    jne bad_password
    
    cmp byte [esi+1], 'H'
    jne bad_password
    
    cmp byte [esi+2], 'O'
    jne bad_password
    
    cmp byte [esi+3], 'C'
    jne bad_password
    
    cmp byte [esi+4], 'O'
    jne bad_password
    
    cmp byte [esi+5], 'L'
    jne bad_password
    
    cmp byte [esi+6], 'A'
    jne bad_password
    
    cmp byte [esi+7], 'T'
    jne bad_password
    
    cmp byte [esi+8], 'I'
    jne bad_password
    
    cmp byte [esi+9], 'N'
    jne bad_password
    
    cmp byte [esi+10], 'E'
    jne bad_password
    
    cmp byte [esi+11], '_'
    jne bad_password
    
    cmp byte [esi+12], 'C'
    jne bad_password
    
    cmp byte [esi+13], '_'
    jne bad_password
    
    cmp byte [esi+14], 'O'
    jne bad_password
    
    cmp byte [esi+15], 'K'
    jne bad_password

    cmp byte [esi+16], 10      ; 10 = '\n'
    je good_password
    cmp byte [esi+16], 0       ; 0 = '\0'
    je good_password
    jmp bad_password         
good_password:
    mov eax, 4      
    mov ebx, 1         
    mov ecx, good_msg
    mov edx, good_len
    int 0x80
    
    mov eax, 1          
    mov ebx, 0
    int 0x80

bad_password:
    mov eax, 4         
    mov ebx, 1      
    mov ecx, bad_msg
    mov edx, bad_len
    int 0x80
    
    mov eax, 1       
    mov ebx, 1
    int 0x80
