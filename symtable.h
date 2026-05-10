#ifndef SYMTABLE_H
#define SYMTABLE_H

typedef struct
{
    char name[64];
    char type[16];
    int value;
}Symbol;

void declare(char* name, int ligne);
void set_value(char* name, int val, int ligne);
int get_value(char* name, int ligne);
int lookup(char* name, int ligne);
#endif