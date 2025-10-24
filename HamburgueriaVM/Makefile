CC = gcc
CFLAGS = -Wall -g

all: parser

parser: parser.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o parser parser.tab.c lex.yy.c -lfl

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

test: parser
	./parser test.ham

clean:
	rm -f parser parser.tab.c parser.tab.h lex.yy.c *.o

.PHONY: all test clean