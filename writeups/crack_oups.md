Identification des symboles Commande utilisée : strings -d oups Résultat : Good Job! → 0x402000 Bad Password! → 0x40200a GOOD_FLAG_16CHAR → 0x402018 On identifie directement la flag stockée en clair dans le binaire ainsi que les messages de sortie.
Analyse du binaire avec objdump -d oups Le programme lit l'entrée utilisateur via stdin (syscall read, fd=0) dans un buffer à 0x402028. Il vérifie que la longueur est exactement 16 caractères. Ensuite il compare byte par byte l'entrée avec la valeur stockée à 0x402018 via une boucle de 16 itérations. Condition vérifiée : user_input[i] == flag[i] pour i de 0 à 15.
Extraction du flag, il est directement lisible via strings à l'adresse 0x402018 : GOOD_FLAG_16CHAR
Validation En exécutant le programme avec ce mot de passe, le message de succès s'affiche, confirmant que la vérification est validée.
echo -n "GOOD_FLAG_16CHAR" | ./oups
Good Job!
