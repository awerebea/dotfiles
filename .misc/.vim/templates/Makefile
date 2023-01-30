# Compile all .cpp files into one target under the current directory.
NAME = a.out
CC = clang++
CFLAGS =  -Wall -Wextra -Werror

# $(wildcard *.cpp /xxx/xxx/*.cpp): get all .cpp files from the current directory and dir "/xxx/xxx/"
SRC := $(wildcard *.cpp)
# $(patsubst %.cpp,%.o,$(SRC)): substitute all ".cpp" file name strings to ".o" file name strings
OBJ := $(patsubst %.cpp,%.o,$(SRC))

all: $(NAME)
$(NAME): $(OBJ)
	$(CC) -o $@ $^
%.o: %.cpp
	$(CC) $(CFLAGS) -c $<
clean:
	rm -rf *.o
fclean: clean
	rm -rf $(NAME)
re: fclean all

run: all
	./a.out

.PHONY: all clean fclean re run
