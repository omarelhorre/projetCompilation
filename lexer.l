/* Distingue majuscules/minuscules (begin ≠ BEGIN) */
%option case-sensitive
%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser.tab.h"

/* Variables pour la gestion des erreurs (ligne/colonne) */
int num_ligne = 1;
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

{fin_ligne}     { num_ligne++; num_colonne = 1; }

{commentaire}   { /* ignorer les commentaires */ }

.    { fprintf(stderr,"[ERREUR LEXICALE] Ligne %d, Colonne %d : caractère '%s' non reconnu\n", num_ligne, num_colonne, yytext); num_colonne += yyleng;}

%%