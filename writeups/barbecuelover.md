Une fois mis sur gidra on ramarque que le binaire ELF64 qui lit 16 caractères + \n et vérifie avec un XOR incrémental.
J'ai donc fais un code python qui permet d'inverser l'opération.
voici le code :
secret = [0x5e, 0x45, 0x59, 0x40, 0x5f, 0x4a, 0x5d, 0x65, 
          0x6e, 0x64, 0x6f, 0x69, 0x7b, 0x75, 0x74, 0x6e]

flag = ''
key = 0x0A

for s in secret:
    flag += chr(s ^ key)
    key += 3

print(flag)
