##
## EPITECH PROJECT, 2019
## make
## File description:
## make
##

SRC	=	libc.asm

OBJ	=	$(SRC:.hs=.o)

NAME	=	libasm.so

all	:	$(NAME)

$(NAME):
		nasm -felf64 libc.asm
		ld -fPIC -shared *.o -o libasm.so

clean:
	rm -f *.o

fclean	:	clean
	rm -f $(NAME)
	rm -f *.so

re	:	fclean all

.PHONY:	all clean fclean re