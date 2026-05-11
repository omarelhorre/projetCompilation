%{
#include <stdio.h>      
#include <stdlib.h>     
#include <string.h>     
#include "symtable.h"  
#include<math.h> 
extern int yylex(void);
extern int yylineno;
extern char *yytext;
extern int prev_tok_line;
extern char prev_tok_text[];
int nb_erreurs;         
void yyerror(const char *s);   
void afficherTabSym();
%}

%token BEGIN_T    
%token END       
%token INT        
%token WRITE      
%token READ       
%token WHILE     
%token DO         
%token OD        
%token IF         
%token THEN       
%token ELSE      
%token FI 
%token FOR
%token TO
%token DONE
%token LPAREN
%token RPAREN

%token ASSIGN  

%token GT         /* >      */
%token LT         /* <      */
%token GE         /* >=     */
%token LE         /* <=     */
%token NE         /* !=     */
%token EQ         /* ==     */
%token SEQ        /* ===    */

/*pour les operations arithmetique*/
%token PLUS
%token MINUS
%token MUL
%token DIV
%token MOD
%token POW

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
    ;

listinstr:
    instr listinstr
    | instr 
    ;

instr:
    INT ID
        { declare($2,yylineno); }

    | ID ASSIGN expr
        { set_value($1, $3,yylineno); }

    | WRITE expr
        { printf("%d\n", $2); }

    | READ LPAREN ID RPAREN
        { lookup($3,yylineno); }

    | WHILE LPAREN cond RPAREN DO listinstr OD

    | IF LPAREN cond RPAREN THEN listinstr FI

    | IF LPAREN cond RPAREN THEN listinstr ELSE listinstr FI

    | FOR ID ASSIGN expr TO expr DO listinstr DONE
        { set_value($2, $4, yylineno); }
    ;

expr:
    expr PLUS expr         { $$ = $1 + $3; }
    | expr MINUS expr      { $$ = $1 - $3; }
    | expr MUL expr        { $$ = $1 * $3; }
    | expr DIV expr
        {
            if ($3 == 0) {
                fprintf(stderr, "division par zero a la ligne %d\n", yylineno);
                nb_erreurs++;
                $$ = 0;
            } else {
                $$ = $1 / $3;
            }
        }
    | expr MOD expr
        {
            if ($3 == 0) {
                fprintf(stderr, "modulo par zero a la ligne %d\n", yylineno);
                nb_erreurs++;
                $$ = 0;
            } else {
                $$ = $1 % $3;
            }
        }
    | expr POW expr        { $$ = (int)pow($1, $3); }
    | ID                   { $$ = lookup($1,yylineno); }
    | NUM                  { $$ = $1; }
    | LPAREN expr RPAREN   { $$ = $2; }
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
    afficherTabSym();
    return 1;
}