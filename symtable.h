#ifndef SYMTABLE_H
#define SYMTABLE_H

typedef struct
{
    char name[64];
    char type[16];
    int value;
}Symbol;

void declare(char* name);
void set_value(char* name, int val);
int get_value(char* name);
int lookup(char* name);
#endif