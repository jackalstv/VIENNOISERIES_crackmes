NAME = yesyoucan

all: $(NAME)

$(NAME): $(NAME).o
	ld -o $(NAME) $(NAME).o

$(NAME).o: $(NAME).asm
	nasm -f elf64 $(NAME).asm -o $(NAME).o

clean:
	rm -f $(NAME).o

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
