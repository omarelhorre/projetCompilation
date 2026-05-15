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
%}

chiffre         [0-9]
lettre          [a-zA-Z]
identifiant     {lettre}({lettre}|{chiffre}|_)*
nombre          {chiffre}+
espace          [ \t]
fin_ligne       \n
commentaire     "//".*

%%

"begin"         { num_colonne += yyleng; return BEGIN_T; }
"end"           { num_colonne += yyleng; return END; }
"int"           { num_colonne += yyleng; return INT; }
"write"         { num_colonne += yyleng; return WRITE; }
"read"          { num_colonne += yyleng; return READ; }
"while"         { num_colonne += yyleng; return WHILE; }
"do"            { num_colonne += yyleng; return DO; }
"od"            { num_colonne += yyleng; return OD; }
"if"            { num_colonne += yyleng; return IF; }
"then"          { num_colonne += yyleng; return THEN; }
"else"          { num_colonne += yyleng; return ELSE; }
"fi"            { num_colonne += yyleng; return FI; }
"for"           { num_colonne += yyleng; return FOR; }
"to"            { num_colonne += yyleng; return TO; }
"done"          { num_colonne += yyleng; return DONE; }

":="            { num_colonne += yyleng; return ASSIGN; }
">="            { num_colonne += yyleng; return GE; }
"<="            { num_colonne += yyleng; return LE; }
"!="            { num_colonne += yyleng; return NE; }
"=="            { num_colonne += yyleng; return EQ; }
"==="           { num_colonne += yyleng; return SEQ; }
"+"             { num_colonne += yyleng; return PLUS; }
"-"             { num_colonne += yyleng; return MINUS; }
"*"             { num_colonne += yyleng; return MUL; }
"/"             { num_colonne += yyleng; return DIV; }
"%"             { num_colonne += yyleng; return MOD; }
"^"             { num_colonne += yyleng; return POW; }
">"             { num_colonne += yyleng; return GT; }
"<"             { num_colonne += yyleng; return LT; }
"("             { num_colonne += yyleng; return LPAREN; }
")"             { num_colonne += yyleng; return RPAREN; }

{identifiant}   { num_colonne += yyleng; yylval.str = strdup(yytext); return ID; }
{nombre}        { num_colonne += yyleng; yylval.num = atoi(yytext); return NUM; }

{espace}        { num_colonne += yyleng; }

{fin_ligne}     { num_colonne = 1; }

{commentaire}   { /* ignorer les commentaires */ }

.    { fprintf(stderr,"ERREUR LEXICALE :Ligne %d, Colonne %d : caractere '%s' non reconnu\n", yylineno, num_colonne, yytext); num_colonne += yyleng;}

%%