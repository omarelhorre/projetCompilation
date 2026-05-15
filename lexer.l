/* Distingue majuscules/minuscules (begin ≠ BEGIN) */
%option case-sensitive
%option noyywrap
%option yylineno
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser.tab.h"

/* Variables pour la gestion des erreurs (ligne/colonne) */

int num_colonne = 1;
int tok_line = 1;
int prev_tok_line = 1;
char prev_tok_text[256] = "";
char cur_tok_text[256] = "";

/* Update token tracking before every non-whitespace token action.
   Bison reads one token ahead, so prev_tok_* holds the actual error token
   while cur_tok_* is the lookahead when yyerror is called. */
#define YY_USER_ACTION \
    if (yytext[0] != ' ' && yytext[0] != '\t' && yytext[0] != '\n') { \
        prev_tok_line = tok_line; \
        tok_line = yylineno; \
        strncpy(prev_tok_text, cur_tok_text, sizeof(prev_tok_text) - 1); \
        strncpy(cur_tok_text, yytext, sizeof(cur_tok_text) - 1); \
    }
%}

chiffre         [0-9]
lettre          [a-zA-Z]
identifiant     {lettre}({lettre}|{chiffre}|_)*
nombre          {chiffre}+
espace          [ \t]
fin_ligne       \n
commentaire     "//".*

%%

"begin"         { return BEGIN_T; }
"end"           { return END; }
"int"           { return INT; }
"write"         { return WRITE; }
"read"          { return READ; }
"while"         { return WHILE; }
"do"            { return DO; }
"od"            { return OD; }
"if"            { return IF; }
"then"          { return THEN; }
"else"          { return ELSE; }
"fi"            { return FI; }
"for"           { return FOR; }
"to"            { return TO; }
"done"          { return DONE; }

":="            { return ASSIGN; }
">="            { return GE; }
"<="            { return LE; }
"!="            { return NE; }
"=="            { return EQ; }
"==="           { return SEQ; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MUL; }
"/"             { return DIV; }
"%"             { return MOD; }
"^"             { return POW; }
">"             { return GT; }
"<"             { return LT; }
"("             { return LPAREN; }
")"             { return RPAREN; }

{identifiant}   { yylval.str = strdup(yytext); return ID; }
{nombre}        { yylval.num = atoi(yytext); return NUM; }

{espace}        { num_colonne++;}

{fin_ligne}     { num_colonne = 1; }

{commentaire}   { /* ignorer les commentaires */ }

.    { fprintf(stderr,"[ERREUR LEXICALE] Ligne %d, Colonne %d : caractère '%s' non reconnu\n", yylineno, num_colonne, yytext); num_colonne += yyleng;}

%%