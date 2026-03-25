Ghidra → Le programme vérifie 16 octets d'entrée via XOR
Tableau expected_xor @ 0x402056 : 3B 34 31 33 30 3B 34 35 2F 2E 2D 35 2F 2C 3F 23
Clé XOR : 0x5A (boucle @ 0x40106a)
Solution : password[i] = expected_xor[i] ^ 0x5A
Flag : ankijanoutwouvey
