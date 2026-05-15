#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtable.h"
#define MAX 256
extern int nb_erreurs;
static Symbol table[MAX];
static int count = 0;


static int find(char* name)
{
    for(int i = 0 ; i < count ; i++)
    {
        if(strcmp(table[i].name, name) == 0)
        return i;
    }
    return -1;
}

void declare(char* name, int ligne)
{
    if(find(name) != -1)
    {
        fprintf(stderr,"Erreur Semantique\nLigne : %d\nVariable : '%s', Probleme  : Variable deja declaree, Hint : Chaque variable ne peut etre declaree qu'une seule fois.\n",ligne,name);
        nb_erreurs++;
        return;
    }
    if(count >= MAX)
    {
        fprintf(stderr,"La table est pleine\n");
        return;
    }
    strncpy(table[count].name, name, 63);
    strncpy(table[count].type, "int", 15);
    table[count].value = 0;
    count++;
    //printf("Declaration : '%s' (int, valeur initiale = 0)\n",name);
}

int lookup(char* name, int ligne)
{
    int index = find(name);
    if(index == -1)
    {
        fprintf(stderr,"Erreur Semantique\nLigne : %d\nVariable : '%s', Probleme  : Variable inexistante,\nHint : Declarez la variable avec 'int %s' avant de l'utiliser.\n",ligne,name,name);
        nb_erreurs++;
        return -1;

    }
    return table[index].value;
}

void set_value(char* name, int val, int ligne)
{
    int i = find(name);
    if(i == -1)
    {
        fprintf(stderr,"Erreur Semantique\nLigne : %d\nVariable : '%s', Probleme  : Variable non declaree,\nHint : Declarez la variable avec 'int %s' avant de l'utiliser.\n",ligne,name,name);
        nb_erreurs++;
        return;
    }
    table[i].value = val;
}


void afficherTabSym()
{
    for(int i = 0 ; i< count ; i++)
    {
        printf("%s ",table[i].name);
        printf("%d ",table[i].value);
        printf("\n");
    }
}
























