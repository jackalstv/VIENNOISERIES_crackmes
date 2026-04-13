NAME = crackme
FLAG = CrackMe_v2_2024!

all: $(NAME)

$(NAME): $(NAME).o
	ld -o $(NAME) $(NAME).o

$(NAME).o: $(NAME).asm
	nasm -f elf64 $(NAME).asm -o $(NAME).o

test: $(NAME)
	@echo "=== Test 1: Bon flag ==="
	@echo "$(FLAG)" | ./$(NAME) && echo "[PASS]" || echo "[FAIL]"
	@echo ""
	@echo "=== Test 2: Mauvais flag ==="
	@echo -n "AAAAAAAAAAAAAAAA" | ./$(NAME) && echo "[FAIL]" || echo "[PASS]"
	@echo ""
	@echo "=== Test 3: Flag trop long ==="
	@echo -n "CrackMe_v2_2024!X" | ./$(NAME) && echo "[FAIL]" || echo "[PASS]"

checksum:
	@python3 gen_flag.py "$(FLAG)"

clean:
	rm -f $(NAME).o

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re test checksum
