# Crackme Pedagogique - x86-64 Linux

## Objectif

Ce crackme est un **support d'apprentissage** pour comprendre :
- L'assembleur x86-64
- Les syscalls Linux
- Les techniques de reverse engineering
- La logique de validation de mots de passe

**Important** : Ce crackme est volontairement simple et bien commente. Il ne doit pas etre utilise tel quel en competition.

---

## 1. Compilation et Execution

### Prerequis

```bash
# Sur Ubuntu/Debian
sudo apt install nasm binutils make
```

### Compilation

```bash
make           # Compile le crackme
make clean     # Supprime les fichiers generes
make rebuild   # Nettoie et recompile
```

### Execution

```bash
make run                            # Lance le crackme interactivement
echo "CrackMe_Easy2025" | ./build/crackme01   # Teste avec le bon mot de passe
```

---

## 2. Logique de Validation

### Vue d'ensemble

```
Entree utilisateur (16 caracteres)
         |
         v
   XOR chaque octet avec 0x42
         |
         v
   Comparer avec tableau attendu
         |
         v
   Bon Travail ! / Mauvais Mot De Passe !
```

### Algorithme detaille

1. **Lecture** : Le programme lit exactement 17 octets (16 caracteres + newline)
2. **Verification longueur** : Si != 17, echec immediat
3. **Boucle XOR** : Pour chaque caractere `i` de 0 a 15 :
   - `resultat = input[i] XOR 0x42`
   - Compare `resultat` avec `expected[i]`
   - Si different, echec immediat
4. **Resultat** : Si tous correspondent, succes

### Mot de passe

Le mot de passe est : **`CrackMe_Easy2025`** (16 caracteres)

Voici le calcul XOR pour chaque caractere :

| Position | Caractere | ASCII (hex) | XOR 0x42 | Attendu |
|----------|-----------|-------------|----------|---------|
| 0        | C         | 0x43        | 0x01     | 0x01    |
| 1        | r         | 0x72        | 0x30     | 0x30    |
| 2        | a         | 0x61        | 0x23     | 0x23    |
| 3        | c         | 0x63        | 0x21     | 0x21    |
| 4        | k         | 0x6B        | 0x29     | 0x29    |
| 5        | M         | 0x4D        | 0x0F     | 0x0F    |
| 6        | e         | 0x65        | 0x27     | 0x27    |
| 7        | _         | 0x5F        | 0x1D     | 0x1D    |
| 8        | E         | 0x45        | 0x07     | 0x07    |
| 9        | a         | 0x61        | 0x23     | 0x23    |
| 10       | s         | 0x73        | 0x31     | 0x31    |
| 11       | y         | 0x79        | 0x3B     | 0x3B    |
| 12       | 2         | 0x32        | 0x70     | 0x70    |
| 13       | 0         | 0x30        | 0x72     | 0x72    |
| 14       | 2         | 0x32        | 0x70     | 0x70    |
| 15       | 5         | 0x35        | 0x77     | 0x77    |

### Pourquoi cette logique est pedagogique

1. **XOR est reversible** : `A XOR B XOR B = A`
   - Facile a comprendre et a reverser
   - Illustre un concept cryptographique fondamental

2. **Verification sequentielle** :
   - Permet de poser des breakpoints et observer chaque iteration
   - Facilite l'analyse pas-a-pas

3. **Pas d'obfuscation** :
   - Code lineaire et previsible
   - Noms de labels explicites (`validation_success`, `validation_failed`)

---

## 3. Guide de Reverse Engineering

### 3.1 Analyse statique avec objdump

```bash
make disasm    # ou: objdump -d -M intel build/crackme01
```

**Que chercher :**

1. **Les syscalls** : Cherche `syscall` et regarde `rax` juste avant
   - `rax = 0` : read (lecture stdin)
   - `rax = 1` : write (ecriture stdout)
   - `rax = 60` : exit

2. **Les comparaisons** : Cherche `cmp` suivi de `jne`/`je`
   ```asm
   cmp    rax, 0x11          ; Compare avec 17 (longueur)
   jne    validation_failed
   ```

3. **Les operations XOR** : Cherche `xor al, 0x42`
   ```asm
   xor    al, 0x42           ; <- Voila la cle XOR !
   ```

4. **Les boucles** : Cherche `inc rcx` + `cmp rcx` + `jl`

### 3.2 Analyse des chaines avec strings

```bash
make strings   # ou: strings build/crackme01
```

**Resultat typique :**
```
Bon Travail !
Mauvais Mot De Passe !
Entrez le mot de passe (16 caracteres):
```

Cela revele les messages de succes/echec et la longueur attendue.

### 3.3 Analyse avec hexdump

```bash
make hexdata   # ou: objdump -s -j .data build/crackme01
```

**Que chercher :**
Le tableau `expected_xored` contient les valeurs attendues apres XOR :
```
0130 2321 290f 271d 0723 313b 7072 7077
```

### 3.4 Analyse dynamique avec GDB

```bash
make debug     # ou: gdb build/crackme01
```

**Session GDB typique :**

```gdb
# Afficher le code en syntaxe Intel
(gdb) set disassembly-flavor intel

# Lister les symboles
(gdb) info functions
    validation_failed
    validation_success
    _start

# Poser un breakpoint sur la boucle de validation
(gdb) disas _start
(gdb) break *0x401XXX    # Adresse de .loop_check

# Lancer le programme
(gdb) run
Entrez le mot de passe: AAAAAAAAAAAAAAAA

# Examiner les registres a chaque iteration
(gdb) info registers al bl rcx

# Avancer d'une instruction
(gdb) si

# Voir la valeur XOR
(gdb) print/x $al        # Caractere entre XOR 0x42
(gdb) print/x $bl        # Valeur attendue
```

**Points cles a observer :**

1. **Avant le XOR** : `al` contient le caractere brut
2. **Apres le XOR** : `al` contient `caractere XOR 0x42`
3. **La comparaison** : `cmp al, bl` compare avec la valeur attendue

### 3.5 Reconstruction du mot de passe

Une fois que tu as trouve :
- La cle XOR : `0x42`
- Le tableau attendu : `01 30 23 21 29 0F 27 1D 07 23 31 3B 70 72 70 77`

Tu peux reconstruire le mot de passe avec Python :

```python
expected = [0x01, 0x30, 0x23, 0x21, 0x29, 0x0F, 0x27, 0x1D,
            0x07, 0x23, 0x31, 0x3B, 0x70, 0x72, 0x70, 0x77]
key = 0x42

password = ''.join(chr(b ^ key) for b in expected)
print(password)  # CrackMe_Easy2025
```

---

## 4. Points d'observation cles

### Dans le desassemblage

| Adresse (relative) | Instruction | Signification |
|--------------------|-------------|---------------|
| Apres `_start`     | `mov rax, 1; syscall` | Affiche le prompt |
| Apres prompt       | `mov rax, 0; syscall` | Lit l'entree |
| Premiere `cmp`     | `cmp rax, 17` | Verifie la longueur |
| Debut boucle       | `xor al, 0x42` | **Cle de transformation** |
| Dans boucle        | `cmp al, bl` | Compare avec attendu |
| Fin boucle         | `cmp rcx, 16` | Limite de la boucle |

### Sauts conditionnels importants

- `jne validation_failed` : Si longueur incorrecte
- `jne validation_failed` : Si caractere incorrect
- `jl .loop_check` : Continue la boucle

---

## 5. Modifier ce crackme pour creer le tien

### 5.1 Changer le mot de passe

1. Choisis un nouveau mot de passe de 16 caracteres
2. Calcule les valeurs XOR :

```python
password = "MonNouveauPass16"
key = 0x42
expected = [hex(ord(c) ^ key) for c in password]
print(', '.join(expected))
```

3. Remplace le tableau `expected_xored` dans le code

### 5.2 Changer la cle XOR

```asm
XOR_KEY:  equ 0x55    ; Nouvelle cle (au lieu de 0x42)
```

N'oublie pas de recalculer `expected_xored` avec la nouvelle cle.

### 5.3 Ajouter des verifications supplementaires

**Exemple : verifier que le premier caractere est une majuscule**

```asm
; Apres avoir lu l'entree
mov     al, [rel input_buffer]
cmp     al, 'A'
jl      validation_failed
cmp     al, 'Z'
jg      validation_failed
```

### 5.4 Utiliser une transformation plus complexe

**Exemple : XOR avec une cle variable (position)**

```asm
.loop_check:
    mov     al, [rsi + rcx]

    ; Cle = 0x42 + position
    mov     dl, cl          ; dl = position (0-15)
    add     dl, XOR_KEY     ; dl = 0x42 + position
    xor     al, dl          ; XOR avec cle variable

    ; ... reste de la comparaison
```

### 5.5 Inverser l'ordre de comparaison

```asm
; Comparer du dernier au premier caractere
    mov     rcx, PASSWORD_LEN - 1   ; rcx = 15

.loop_check:
    ; ... charger et XOR ...

    dec     rcx                     ; rcx--
    jge     .loop_check             ; tant que rcx >= 0
```

### 5.6 Ajouter un checksum

```asm
; Calculer la somme des caracteres
    xor     rbx, rbx            ; rbx = somme = 0
    xor     rcx, rcx

.sum_loop:
    movzx   rax, byte [rsi + rcx]
    add     rbx, rax
    inc     rcx
    cmp     rcx, PASSWORD_LEN
    jl      .sum_loop

; Verifier le checksum
    cmp     rbx, EXPECTED_SUM   ; Somme attendue
    jne     validation_failed
```

---

## 6. Registres x86-64 - Aide-memoire

| Registre | Usage dans ce crackme |
|----------|----------------------|
| `rax`    | Numero de syscall / valeur de retour |
| `rdi`    | 1er argument syscall |
| `rsi`    | 2e argument syscall / adresse buffer |
| `rdx`    | 3e argument syscall / longueur |
| `rcx`    | Compteur de boucle |
| `al`     | Caractere courant (8 bits bas de rax) |
| `bl`     | Valeur attendue (8 bits bas de rbx) |

---

## 7. Syscalls Linux - Aide-memoire

| Numero | Nom | Arguments |
|--------|-----|-----------|
| 0 | read | rdi=fd, rsi=buf, rdx=count |
| 1 | write | rdi=fd, rsi=buf, rdx=count |
| 60 | exit | rdi=code |

File descriptors : 0=stdin, 1=stdout, 2=stderr

---

## 8. Ressources pour aller plus loin

- [x86-64 Reference](https://www.felixcloutier.com/x86/)
- [Linux Syscall Table](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/)
- [GDB Cheatsheet](https://darkdust.net/files/GDB%20Cheat%20Sheet.pdf)
- [Intel/NASM Syntax](https://www.nasm.us/doc/)
