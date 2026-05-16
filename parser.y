%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdarg.h>
#include "symtable.h"

extern int  yylex(void);
extern char prev_tok_text[];
extern char cur_tok_text[];

int  nb_erreurs = 0;
void yyerror(const char *msg);

static int  erreur_active         = 0;
static int  err_pending           = 0;
static int  err_pending_ligne     = 0;
static char err_pending_msg[512]  = "";

/* Point d'affichage unique : un seul message par episode d'erreur. Tant que
   le parseur n'a pas reanalyse une instruction complete (instr_ok), les
   erreurs suivantes sont des cascades et sont ignorees. */
static void signaler_erreur(int ligne, const char *msg)
{
    if (erreur_active)
        return;

    fprintf(stderr, "  [Ligne %d] %s\n", ligne, msg);
    erreur_active = 1;
    nb_erreurs++;
}

static void vider_erreur_en_attente(void)
{
    if (err_pending) {
        err_pending = 0;
        signaler_erreur(err_pending_ligne, err_pending_msg);
    }
}

static void instr_ok(void)
{
    vider_erreur_en_attente();
    erreur_active = 0;
}

/* Message specifique issu d'une regle de recuperation : il remplace le
   message generique mis en attente par yyerror pour la meme erreur. */
void enregistrer_erreur(int ligne, const char *fmt, ...)
{
    va_list ap;
    char    buf[512];

    va_start(ap, fmt);
    vsnprintf(buf, sizeof(buf), fmt, ap);
    va_end(ap);

    err_pending = 0;
    signaler_erreur(ligne, buf);
}

/* Vrai si le token courant ferme un bloc/programme : dans ce cas une erreur
   d'instruction signifie en realite qu'un mot-cle de fermeture manque. */
static int jeton_fermeture(void)
{
    const char *t = cur_tok_text;
    return (t[0] == '\0'
            || strcmp(t, "end")  == 0
            || strcmp(t, "done") == 0
            || strcmp(t, "od")   == 0
            || strcmp(t, "fi")   == 0
            || strcmp(t, "else") == 0);
}

/* Erreur survenant apres le corps d'un bloc : le mot-cle de fermeture n'a pas
   pu etre reconnu. Cela vient soit d'un closer manquant, soit (souvent) d'une
   instruction invalide dans le corps qui a desynchronise l'analyse. On ne
   pretend donc PAS que le closer est forcement absent. */
static void erreur_bloc_non_ferme(int ligne, const char *bloc, const char *closer)
{
    enregistrer_erreur(ligne,
        "Bloc '%s' non ferme correctement : '%s' attendu ici "
        "(une instruction du corps est probablement invalide ou incomplete, "
        "ou '%s' est manquant/mal place). Token rencontre : '%s'",
        bloc, closer, closer,
        cur_tok_text[0] ? cur_tok_text : "fin de fichier");
}

static void erreur_instr(int ligne, const char *msg_defaut)
{
    if (jeton_fermeture())
        enregistrer_erreur(ligne,
            "Bloc ou programme non ferme : un mot-cle de fermeture "
            "('done', 'od', 'fi' ou 'end') est manquant avant '%s'",
            cur_tok_text[0] ? cur_tok_text : "la fin du fichier");
    else
        enregistrer_erreur(ligne, "%s", msg_defaut);
}
%}
%expect 1
%define parse.lac full
%locations

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
            enregistrer_erreur(@1.first_line,"Le programme doit commencer par le mot-cle 'begin'");
            yyerrok;
        }
    | BEGIN_T listinstr error
        {
            enregistrer_erreur(@3.first_line,"Structure du programme invalide : impossible de fermer le programme avec 'end' (un mot-cle est probablement en trop ou mal place, ou une instruction est incomplete avant 'end'). Dernier token analyse : '%s'", prev_tok_text);
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
        { declare($2, @2.first_line); free($2); instr_ok(); }

    | INT error
        { enregistrer_erreur(@1.first_line, "Identifiant attendu apres le mot-cle 'int'"); yyerrok; }

    | ID ASSIGN expr
        { set_value($1, $3, @1.first_line); free($1); instr_ok(); }

    | ID ASSIGN error
        {
            char d[256];
            snprintf(d, sizeof(d),
                "Expression invalide dans l'affectation de la variable '%s'"
                " (token inattendu : '%s')", $1, prev_tok_text);
            erreur_instr(@1.first_line, d);
            free($1);
            yyerrok;
        }

    | ID error
        {
            char d[256];
            snprintf(d, sizeof(d),
                "Operateur d'affectation ':=' attendu apres la variable '%s'", $1);
            erreur_instr(@1.first_line, d);
            free($1);
            yyerrok;
        }

    | WRITE expr
        { printf("%d\n", $2); instr_ok(); }

    | WRITE error
        { erreur_instr(@1.first_line, "Expression invalide apres le mot-cle 'write'"); yyerrok; }

    | READ LPAREN ID RPAREN
        { lookup($3, @3.first_line); free($3); instr_ok(); }

    | READ LPAREN ID error
        {
            enregistrer_erreur(@1.first_line, "Parenthese fermante ')' attendue dans 'read(...)'");
            free($3);
            yyerrok;
        }
    | READ LPAREN error
        { enregistrer_erreur(@1.first_line, "Identifiant attendu dans 'read(...)'"); yyerrok; }
    | READ error
        { enregistrer_erreur(@1.first_line, "Parenthese ouvrante '(' attendue apres le mot-cle 'read'"); yyerrok; }

    | WHILE LPAREN cond RPAREN DO listinstr OD
        { instr_ok(); }

    | WHILE LPAREN cond RPAREN DO listinstr error
        { erreur_bloc_non_ferme(@1.first_line, "while", "od"); yyerrok; }

    | WHILE LPAREN cond RPAREN error
        { enregistrer_erreur(@1.first_line, "Mot-cle 'do' attendu apres la condition du 'while'"); yyerrok; }

    | WHILE LPAREN cond error
        { enregistrer_erreur(@1.first_line, "Parenthese fermante ')' attendue dans la condition du 'while'"); yyerrok; }

    | WHILE LPAREN error
        { enregistrer_erreur(@1.first_line, "Condition invalide dans 'while(...)'"); yyerrok; }

    | WHILE error
        { enregistrer_erreur(@1.first_line, "Parenthese ouvrante '(' attendue apres le mot-cle 'while'"); yyerrok; }

    | IF LPAREN cond RPAREN THEN listinstr FI
        { instr_ok(); }

    | IF LPAREN cond RPAREN THEN listinstr ELSE listinstr FI
        { instr_ok(); }

    | IF LPAREN cond RPAREN THEN listinstr ELSE listinstr error
        { erreur_bloc_non_ferme(@1.first_line, "if-else", "fi"); yyerrok; }

    | IF LPAREN cond RPAREN THEN listinstr error
        { erreur_bloc_non_ferme(@1.first_line, "if", "fi' ou 'else"); yyerrok; }

    | IF LPAREN cond RPAREN error
        { enregistrer_erreur(@1.first_line, "Mot-cle 'then' attendu apres la condition du 'if'"); yyerrok; }

    | IF LPAREN cond error
        { enregistrer_erreur(@1.first_line, "Parenthese fermante ')' attendue dans la condition du 'if'"); yyerrok; }

    | IF LPAREN error
        { enregistrer_erreur(@1.first_line, "Condition invalide dans 'if(...)'"); yyerrok; }

    | IF error
        { enregistrer_erreur(@1.first_line, "Parenthese ouvrante '(' attendue apres le mot-cle 'if'"); yyerrok; }

    | FOR ID ASSIGN expr TO expr DO listinstr DONE
        { set_value($2, $4, @2.first_line); free($2); instr_ok(); }

    | FOR ID ASSIGN expr TO expr DO listinstr error
        {
            erreur_bloc_non_ferme(@1.first_line, "for", "done");
            free($2);
            yyerrok;
        }

    | FOR ID ASSIGN expr TO error
        {
            enregistrer_erreur(@1.first_line, "Expression invalide apres 'to' dans la boucle 'for'");
            free($2);
            yyerrok;
        }

    | FOR ID ASSIGN error
        {
            enregistrer_erreur(@1.first_line, "Expression invalide apres ':=' dans la boucle 'for'");
            free($2);
            yyerrok;
        }

    | FOR ID error
        {
            enregistrer_erreur(@2.first_line,
                "Operateur d'affectation ':=' attendu apres la variable '%s' dans la boucle 'for'", $2);
            free($2);
            yyerrok;
        }

    | FOR error
        { enregistrer_erreur(@1.first_line, "Identifiant attendu apres le mot-cle 'for'"); yyerrok; }
    ;

expr:
    expr PLUS expr         { $$ = $1 + $3; }
    | expr MINUS expr      { $$ = $1 - $3; }
    | expr MUL expr        { $$ = $1 * $3; }
    | expr DIV expr
        {
            if ($3 == 0) {
                enregistrer_erreur(@2.first_line, "Division par zero");
                $$ = 0;
            } else {
                $$ = $1 / $3;
            }
        }
    | expr MOD expr
        {
            if ($3 == 0) {
                enregistrer_erreur(@2.first_line, "Modulo par zero");
                $$ = 0;
            } else {
                $$ = $1 % $3;
            }
        }
    | expr POW expr        { $$ = (int)pow($1, $3); }
    | ID                   { $$ = lookup($1, @1.first_line); free($1); }
    | NUM                  { $$ = $1; }
    | LPAREN expr RPAREN   { $$ = $2; }

    | LPAREN expr error
        {
            enregistrer_erreur(@1.first_line,"Parenthese fermante ')' manquante pour fermer l'expression entre parentheses (recu : '%s')", prev_tok_text);
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
    (void)msg;
    vider_erreur_en_attente();

    err_pending       = 1;
    err_pending_ligne = yylloc.first_line;
    snprintf(err_pending_msg, sizeof(err_pending_msg),
             "Erreur de syntaxe pres de '%s'", cur_tok_text);
}

int main(void)
{
    yyparse();
    vider_erreur_en_attente();

    if (nb_erreurs == 0) {
        printf("Programme correcte\n");
        return 0;
    }
    printf("Programme incorrecte\n");
    return 1;
}