all: parser

parser: parser.tab.c lex.yy.c symtable.c symtable.h
	gcc -o parser parser.tab.c lex.yy.c symtable.c -lm -lfl

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

test: parser
	@for f in tests/*.txt; do \
		echo "===== $$f ====="; \
		./parser < $$f; \
		echo; \
	done

clean:
	rm -f parser parser.tab.c parser.tab.h lex.yy.c

.PHONY: all clean test

