/* Distingue majuscules/minuscules (begin ≠ BEGIN) */
%option case-sensitive
%option noyywrap
%option yylineno
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser.tab.h"

extern int nb_erreurs;

/* Variables pour la gestion des erreurs (ligne/colonne) */

int num_colonne = 1;
int tok_line = 1;
int prev_tok_line = 1;
char prev_tok_text[256] = "";
char cur_tok_text[256] = "";

/* Renseigne la position (ligne/colonne) de CHAQUE token pour Bison (%locations)
   et met a jour le suivi de colonne, qui etait auparavant inoperant. */
#define YY_USER_ACTION \
    yylloc.first_line   = yylineno; \
    yylloc.first_column = num_colonne; \
    if(yytext[0] != ' ' && yytext[0] != '\t' && yytext[0] != '\n') { \
        prev_tok_line = tok_line; \
        tok_line = yylineno; \
        strncpy(prev_tok_text, cur_tok_text, sizeof(prev_tok_text) - 1); \
        prev_tok_text[sizeof(prev_tok_text) - 1] = '\0'; \
        strncpy(cur_tok_text, yytext, sizeof(cur_tok_text) - 1); \
        cur_tok_text[sizeof(cur_tok_text) - 1] = '\0'; \
    } \
    num_colonne += yyleng; \
    yylloc.last_line   = yylineno; \
    yylloc.last_column = num_colonne;

static void suggerer(const char *car) {
    /* Operateurs courants mal saisis */
    if (strcmp(car, "=")  == 0)
        fprintf(stderr, "     Suggestion : affectation -> ':='  |  egalite -> '=='\n");
    else if (strcmp(car, "!") == 0)
        fprintf(stderr, "     Suggestion : different de -> '!='\n");
    else if (strcmp(car, "&") == 0 || strcmp(car, "|") == 0)
        fprintf(stderr, "     Suggestion : les operateurs logiques ne sont pas supportes.\n");
    else if (strcmp(car, ";") == 0)
        fprintf(stderr, "     Suggestion : ce langage n'utilise pas de ';' en fin d'instruction.\n");
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

{identifiant}   {
                    yylval.str = strdup(yytext);
                    if (yylval.str == NULL) {
                        fprintf(stderr, "[ERREUR FATALE] Memoire insuffisante\n");
                        exit(EXIT_FAILURE);
                    }
                    return ID;
                }
{nombre}        { yylval.num = (int)strtol(yytext, NULL, 10); return NUM; }

{espace}        { /* colonnes deja comptees par YY_USER_ACTION */ }

{fin_ligne}     { num_colonne = 1; }

{commentaire}   { /* ignorer les commentaires */ }

.   {
        fprintf(stderr, "[ERREUR LEXICALE] Ligne %d, Colonne %d : caractere '%s' non reconnu\n",
                yylloc.first_line, yylloc.first_column, yytext);
        suggerer(yytext);
        nb_erreurs++;
    }

%%