# ==============================================================================
# Makefile pour le crackme pedagogique
# ==============================================================================

# Nom de l'executable final
TARGET = crackme01

# Repertoires
SRC_DIR = src
BUILD_DIR = build

# Fichiers sources et objets
ASM_SRC = $(SRC_DIR)/main.asm
OBJ_FILE = $(BUILD_DIR)/main.o

# Outils
NASM = nasm
LD = ld

# Options de compilation
# -f elf64 : format de sortie ELF 64 bits
# -g : inclure les symboles de debug (utile pour gdb)
# -F dwarf : format de debug DWARF
NASM_FLAGS = -f elf64 -g -F dwarf

# Options de linkage
# Pas d'options speciales, on fait un binaire statique minimal
LD_FLAGS =

# ==============================================================================
# Regles de compilation
# ==============================================================================

# Regle par defaut : compiler tout
all: $(BUILD_DIR)/$(TARGET)

# Creer le repertoire build si necessaire
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Assembler le fichier .asm en fichier objet .o
$(OBJ_FILE): $(ASM_SRC) | $(BUILD_DIR)
	$(NASM) $(NASM_FLAGS) $(ASM_SRC) -o $(OBJ_FILE)

# Linker le fichier objet en executable
$(BUILD_DIR)/$(TARGET): $(OBJ_FILE)
	$(LD) $(LD_FLAGS) $(OBJ_FILE) -o $(BUILD_DIR)/$(TARGET)
	@echo ""
	@echo "=== Compilation terminee ==="
	@echo "Executable: $(BUILD_DIR)/$(TARGET)"
	@echo "Taille: $$(stat -c%s $(BUILD_DIR)/$(TARGET)) octets"
	@echo ""

# ==============================================================================
# Regles utilitaires
# ==============================================================================

# Nettoyer les fichiers generes
clean:
	rm -f $(BUILD_DIR)/*.o $(BUILD_DIR)/$(TARGET)

# Nettoyer et recompiler
rebuild: clean all

# Executer le crackme
run: $(BUILD_DIR)/$(TARGET)
	./$(BUILD_DIR)/$(TARGET)

# Tester avec le bon mot de passe
test: $(BUILD_DIR)/$(TARGET)
	@echo "Test avec le bon mot de passe:"
	@echo "CrackMe_Easy2025" | ./$(BUILD_DIR)/$(TARGET)
	@echo ""
	@echo "Test avec un mauvais mot de passe:"
	@echo "wrongpassword123" | ./$(BUILD_DIR)/$(TARGET) || true

# ==============================================================================
# Regles d'analyse (pour le reverse engineering)
# ==============================================================================

# Afficher le desassemblage avec objdump
disasm: $(BUILD_DIR)/$(TARGET)
	objdump -d -M intel $(BUILD_DIR)/$(TARGET)

# Afficher les chaines de caracteres
strings: $(BUILD_DIR)/$(TARGET)
	strings $(BUILD_DIR)/$(TARGET)

# Afficher les sections ELF
sections: $(BUILD_DIR)/$(TARGET)
	readelf -S $(BUILD_DIR)/$(TARGET)

# Afficher les symboles
symbols: $(BUILD_DIR)/$(TARGET)
	nm $(BUILD_DIR)/$(TARGET)

# Afficher l'en-tete ELF
headers: $(BUILD_DIR)/$(TARGET)
	readelf -h $(BUILD_DIR)/$(TARGET)

# Hexdump de la section .data
hexdata: $(BUILD_DIR)/$(TARGET)
	objdump -s -j .data $(BUILD_DIR)/$(TARGET)

# Lancer gdb avec le binaire
debug: $(BUILD_DIR)/$(TARGET)
	gdb $(BUILD_DIR)/$(TARGET)

# ==============================================================================
# Aide
# ==============================================================================

help:
	@echo "Commandes disponibles:"
	@echo "  make          - Compiler le crackme"
	@echo "  make clean    - Supprimer les fichiers generes"
	@echo "  make rebuild  - Nettoyer et recompiler"
	@echo "  make run      - Executer le crackme"
	@echo "  make test     - Tester avec les mots de passe"
	@echo ""
	@echo "Commandes d'analyse:"
	@echo "  make disasm   - Desassembler avec objdump"
	@echo "  make strings  - Afficher les chaines"
	@echo "  make sections - Afficher les sections ELF"
	@echo "  make symbols  - Afficher les symboles"
	@echo "  make headers  - Afficher l'en-tete ELF"
	@echo "  make hexdata  - Hexdump de la section .data"
	@echo "  make debug    - Lancer gdb"

.PHONY: all clean rebuild run test disasm strings sections symbols headers hexdata debug help
