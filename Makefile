all: parser

parser: parser.tab.c lex.yy.c symtable.c symtable.h
	gcc -o parser parser.tab.c lex.yy.c symtable.c -lm -lfl

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

<<<<<<< HEAD
=======

>>>>>>> c98a4debc03c9cc71778ee0f0eabff8ad064f723
clean:
	rm -f parser parser.tab.c parser.tab.h lex.yy.c

