Crackme x86-64 qui génère un password aléatoire (RDTSC), inverse l'input utilisateur et le compare au password.
Localisation : 0x4010ab - 0x4010d7

004010ab  MOV RAX, qword [user_input]      ; Lit 8 premiers octets
004010b3  MOV RBX, 0x5456524d5446554e      ; Constante hardcodée
004010bd  CMP RAX, RBX
004010c0  JNZ _start.restore_and_continue

004010c2  MOV RAX, qword [0x402174]        ; Lit 8 octets suivants  
004010ca  MOV RBX, 0x534c4f5542494553      ; 2ème constante
004010d4  CMP RAX, RBX
004010d7  JZ _start.is_valid 

on décode le little indian :
0x5456524d5446554e => NUFTMRTV
0x534c4f5542494553 => SEIBOULS

flag = NUFTMRTVSEIBOULS
