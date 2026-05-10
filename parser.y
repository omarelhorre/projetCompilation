%{
#include <stdio.h>      
#include <stdlib.h>     
#include <string.h>     
#include "symtable.h"  
#include "symtable.c"
#include<math.h> 
extern int yylex(void);        
extern int yylineno;           
extern char *yytext; 
int nb_erreurs=0;         
void yyerror(const char *s);   
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

%left MINUS

%left MUL DIV MOD

%right POW   

%start program  

/* les regles de gramaire */

%%

program:
    BEGIN_T listinstr END
    ;

listinstr:
      instr
    | instr listinstr
    ;

instr:
INT ID
        { declare($2); }

    | ID ASSIGN expr
        { set_value($1, $3); }

    | WRITE expr

    | READ LPAREN ID RPAREN
        { lookup($3); }

    | WHILE LPAREN cond RPAREN DO listinstr OD

    | IF LPAREN cond RPAREN THEN listinstr FI

    | IF LPAREN cond RPAREN THEN listinstr ELSE listinstr FI
    ;

expr:
      expr MINUS expr      { $$ = $1 - $3; }
    | expr MUL expr        { $$ = $1 * $3; }
    | expr DIV expr        { $$ = $1 / $3; }
    | expr MOD expr        { $$ = $1 % $3; }
    | expr POW expr        { $$ = (int)pow($1, $3); }
    | ID                   { $$ = lookup($1); }
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
    fprintf(stderr, " Erreur syntaxique à la ligne %d\n", yylineno);
    fprintf(stderr, "  Message : %s\n", msg);
    fprintf(stderr, "  Token : '%s'\n", yytext);
    nb_erreurs++;
}

int main()
{
    int result = yyparse();
    
    if (result == 0 && nb_erreurs == 0) {
        printf(" Programme correcte\n");
    } else {
        printf(" Programme incorrecte\n");
    }
    
    return result;
}