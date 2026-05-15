#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtable.h"
#define MAX 256
extern int nb_erreurs;
static Symbol table[MAX];
static int count;


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
        fprintf(stderr,"variable %s déja declare dans la table a la ligne %d\n",name,ligne);
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
    printf("table de symbole : declaration %s \n",name);
}

int lookup(char* name, int ligne)
{
    int index = find(name);
    if(index == -1)
    {

            fprintf(stderr,"variable inexistante %s a la ligne %d\n",name,ligne+1);
        
    
        nb_erreurs++;
        return 0;}

    
    return table[index].value;
}

void set_value(char* name, int val, int ligne)
{
    int i = find(name);
    if(i == -1)
    {

        fprintf(stderr,"variable n'est pas declaree %s a la ligne %d\n",name,ligne);
        nb_erreurs++;
        return;
    }
    table[i].value = val;
}
//to be in .l
