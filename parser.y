%{
#include <stdio.h>      
#include <stdlib.h>     
#include <string.h>     
#include "symtable.h"  
#include<math.h> 
#include <stdarg.h>

extern int yylex(void);
extern int yylineno;
extern char *yytext;
extern int prev_tok_line;
extern char prev_tok_text[];
extern char cur_tok_text[];

int nb_erreurs =0;         
void yyerror(const char *s);   
void afficherTabSym();

#define MAX_ERREURS 256
typedef struct {
    int  ligne;
    char message[512];
} Erreur;

static Erreur liste_erreurs[MAX_ERREURS];
static int    nb_erreurs_liste = 0;

/* Enregistre une erreur dans la liste ET l'affiche immediatement */
void enregistrer_erreur(int ligne, const char *fmt, ...) {
    va_list ap;
    char buf[512];
    va_start(ap, fmt);
    vsnprintf(buf, sizeof(buf), fmt, ap);
    va_end(ap);

    /* Affichage immediat sur stderr */
    fprintf(stderr, "  [Ligne %d] %s\n", ligne, buf);

    /* Enregistrement pour le rapport final */
    if (nb_erreurs_liste < MAX_ERREURS) {
        liste_erreurs[nb_erreurs_liste].ligne = ligne;
        strncpy(liste_erreurs[nb_erreurs_liste].message, buf, 511);
        nb_erreurs_liste++;
    }
    nb_erreurs++;
}

%}
%expect 1
%define parse.lac full

%token BEGIN_T END INT WRITE READ
%token WHILE DO OD
%token IF THEN ELSE FI
%token FOR TO DONE
%token LPAREN RPAREN
%token ASSIGN

%token GT LT GE LE NE EQ SEQ   /* >, <, >=, <=, !=, ==, === */
%token PLUS MINUS MUL DIV MOD POW


/*union pour stocker les valeurs de token */

%union {
    int num;     //les nombres     
    char *str;  //les chaines
}


%token <num> NUM
%token <str> ID
%type <num> expr

/*declaration des priorites*/

%nonassoc GT LT GE LE NE EQ SEQ    /*plus faible comparaison*/

%left PLUS MINUS

%left MUL DIV MOD

%right POW   

%start program  

/* les regles de gramaire */

%%

program:
    BEGIN_T listinstr END
        { /* OK */}

    | error listinstr END
        {
            enregistrer_erreur(1,"Le programme doit commencer par le mot-cle 'begin'");
            yyerrok;
        }
    | BEGIN_T listinstr error
        {
            enregistrer_erreur(prev_tok_line,"Mot-cle 'end' attendu pour fermer le programme (dernier token lu : '%s')", prev_tok_text);
            yyerrok;
        }
    ;

listinstr:
    instr listinstr
    | instr 
    | error listinstr
        {
            yyerrok;
            yyclearin;
        }
    ;

instr:
    INT ID
        { declare($2,yylineno); }

    | INT error
        { enregistrer_erreur(yylineno, "Identifiant attendu apres 'int'"); yyerrok; }

    | ID ASSIGN expr
        { set_value($1, $3,yylineno); }

    | ID ASSIGN error
        {
        enregistrer_erreur(yylineno,
            "Expression invalide dans l'affectation de '%s'"
            " (token inattendu : '%s')", $1, prev_tok_text);
        yyerrok;
    }
    
    | ID error
        { enregistrer_erreur(yylineno, "Operateur ':=' attendu apres '%s'", $1); yyerrok; }

    | WRITE expr
        { printf("%d\n", $2); }

    | WRITE error
        { enregistrer_erreur(yylineno, "Expression invalide apres 'write'"); yyerrok; }

    | READ LPAREN ID RPAREN
        { lookup($3,yylineno); }
    
    | READ LPAREN ID error
        { enregistrer_erreur(yylineno, "'Pfer' attendu dans 'read'"); yyerrok; }
    | READ LPAREN error
        { enregistrer_erreur(yylineno, "Identifiant attendu dans 'read(...)'"); yyerrok; }
    | READ error
        { enregistrer_erreur(yylineno, "'Pouv' attendu apres 'read'"); yyerrok; }

    | WHILE LPAREN cond RPAREN DO listinstr OD

    | WHILE LPAREN cond RPAREN DO listinstr error
        { enregistrer_erreur(yylineno, "'od' attendu pour fermer 'while'"); yyerrok; }

    | WHILE LPAREN cond RPAREN error
        { enregistrer_erreur(yylineno, "'do' attendu apres condition 'while'"); yyerrok; }

    | WHILE LPAREN cond error
        { enregistrer_erreur(yylineno, "'Pfer' attendu dans condition 'while'"); yyerrok; }

    | WHILE LPAREN error
        { enregistrer_erreur(yylineno, "Condition invalide dans 'while(...)'"); yyerrok; }

    | WHILE error
        { enregistrer_erreur(yylineno, "'Pouv' attendu apres 'while'"); yyerrok; }

    | IF LPAREN cond RPAREN THEN listinstr FI

    | IF LPAREN cond RPAREN THEN listinstr ELSE listinstr FI

    | IF LPAREN cond RPAREN THEN listinstr ELSE listinstr error
        { enregistrer_erreur(yylineno, "'fi' attendu pour fermer 'if-else'"); yyerrok; }

    | IF LPAREN cond RPAREN THEN listinstr error
        { enregistrer_erreur(yylineno, "'fi' ou 'else' attendu dans 'if'"); yyerrok; }

    | IF LPAREN cond RPAREN error
        { enregistrer_erreur(yylineno, "'then' attendu apres condition 'if'"); yyerrok; }

    | IF LPAREN cond error
        { enregistrer_erreur(yylineno, "'Pfer' attendu dans condition 'if'"); yyerrok; }

    | IF LPAREN error
        { enregistrer_erreur(yylineno, "Condition invalide dans 'if(...)'"); yyerrok; }

    | IF error
        { enregistrer_erreur(yylineno, "'Pouv' attendu apres 'if'"); yyerrok; }

    | FOR ID ASSIGN expr TO expr DO listinstr DONE
        { set_value($2, $4, yylineno); }

    | FOR ID ASSIGN expr TO expr DO listinstr error
        { enregistrer_erreur(yylineno, "'done' attendu pour fermer 'for'"); yyerrok; }

    | FOR ID ASSIGN expr TO error
        { enregistrer_erreur(yylineno, "Expression invalide apres 'to' dans 'for'"); yyerrok; }

    | FOR ID ASSIGN error
        { enregistrer_erreur(yylineno, "Expression invalide apres ':=' dans 'for'"); yyerrok; }

    | FOR ID error
        { enregistrer_erreur(yylineno, "':=' attendu apres '%s' dans 'for'", $2); yyerrok; }

    | FOR error
        { enregistrer_erreur(yylineno, "Identifiant attendu apres 'for'"); yyerrok; }
    ;

expr:
    expr PLUS expr         { $$ = $1 + $3; }
    | expr MINUS expr      { $$ = $1 - $3; }
    | expr MUL expr        { $$ = $1 * $3; }
    | expr DIV expr
        {
            if ($3 == 0) {
                enregistrer_erreur(yylineno, "Division par zero");
                $$ = 0;
            } else {
                $$ = $1 / $3;
            }
        }
    | expr MOD expr
        {
            if ($3 == 0) {
                enregistrer_erreur(yylineno, "Modulo par zero");
                $$ = 0;
            } else {
                $$ = $1 % $3;
            }
        }
    | expr POW expr        { $$ = (int)pow($1, $3); }
    | ID                   { $$ = lookup($1,yylineno); }
    | NUM                  { $$ = $1; }
    | LPAREN expr RPAREN   { $$ = $2; }
    
    | LPAREN expr error
        {
            enregistrer_erreur(yylineno,"'Pfer' manquant pour fermer l'expression entre parentheses (recu : '%s')", prev_tok_text);
            $$ = $2;
            yyerrok;
        }
    ;

cond:
    expr GT expr
    | expr LT expr
    | expr GE expr
    | expr LE expr
    | expr NE expr
    | expr EQ expr
    | expr SEQ expr
    ;

%%

void yyerror(const char *msg) {
    fprintf(stderr, "Erreur syntaxique a la ligne %d : token inattendu '%s'\n", prev_tok_line, prev_tok_text);
    fprintf(stderr, "  Message : %s\n", msg);
    nb_erreurs++;
}

int main(void)
{
    yyparse();

    if (nb_erreurs == 0) {
        printf("Programme correcte\n");
        return 0;
    }
    printf("Programme incorrecte\n");
    return 1;
}