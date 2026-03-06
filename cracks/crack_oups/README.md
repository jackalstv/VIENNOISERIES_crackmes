
# Crack – crackme 'oups'

## Description
Patche le binaire `oups` pour remplacer la flag originale par `CR4CK1NG5N0TCR1M`.

## Compilation
nasm -f elf64 crack_oups.s -o crack_oups.o
ld -o crack_oups crack_oups.o

## Usage
./crack_oups <binaire_oups>

## Résultat après patch
echo -n "CR4CK1NG5N0TCR1M" | ./oups  → Good Job!
