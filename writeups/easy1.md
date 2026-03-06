Identification des symboles Commande utilisée : strings -d easy1 Résultat : on identifie directement le flag stocké en clair EASY_FLAG_123456 ainsi que le label correct_flag à 0x402018 et les messages Good Job! et Bad Password!.
Analyse du binaire avec objdump objdump -d easy1 Le programme lit l'entrée via stdin dans buffer à 0x402028. Il vérifie que la longueur est exactement 17 bytes (16 chars + newline). Ensuite il compare byte par byte l'input avec le flag stocké à 0x402018 via compare_loop sur 16 itérations.
Extraction du flag Le flag est directement lisible via strings à l'adresse 0x402018 : EASY_FLAG_123456
Validation En exécutant le programme avec ce mot de passe.
