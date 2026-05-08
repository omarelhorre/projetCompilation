#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtable.h"

#define MAX 256

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

void declare(char* name)
{
    if(find(name) != -1)
    {
        fprintf(stderr,"variable %s déja declaré dans la table\n",name);
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
    printf("table de symbole : declaration %s \n",name);
}

int lookup(char* name)
{
    int index = find(name);
    if(index == -1)
    {
        fprintf(stderr,"variable inexistante");
        return -1;
    }
    return table[index].value;
}

void set_value(char* name, int val)
{
    int i = find(name);
    if(i == -1)
    {
        fprintf(stderr,"variable inexistante");
        return;
    }
    table[i].value = val;
}