Write-up – Crackme 'crackcrack'
1. Identification des symboles
Commande utilisée :
nm -n crackcrack | egrep 'secret$|_verify$|user_input$'
Résultat :
_verify → 0x40103f
secret → 0x402038
user_input → 0x402048
On identifie la fonction de vérification, la variable secrète et la zone mémoire d’entrée utilisateur.
2. Analyse de la fonction "verify"
mov al, [rcx+0x402048]
xor al, 0x42
cmp al, [rcx+0x402038]
jne _fail
cmp rcx, 0x10
jl _verify
Le programme lit l’entrée utilisateur caractère par caractère. - Applique un XOR 0x42. -
Compare le résultat avec la variable 'secret'.  Répète l’opération sur 16 caractères (0x10).
Condition vérifiée :
(user_input[i] XOR 0x42) == secret[i]
3. Extraction du secret
x/16bx 0x402038
26 2d 30 2d 32 30 36 3b 21 2a 23 36 27 2e 27 36
4. Calcul du mot de passe
secret = [
0x26,0x2d,0x30,0x2d,0x32,0x30,0x36,0x3b,
0x21,0x2a,0x23,0x36,0x27,0x2e,0x27,0x36
]
password = ''.join(chr(b ^ 0x42) for b in secret)
print(password)
Mot de passe obtenu : doroprtychatelet
5. Validation
En exécutant le programme avec ce mot de passe, le message de succès s’affiche, confirmant que
la vérification est validée.
