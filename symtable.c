#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtable.h"

#define MAX 256

extern int nb_erreurs;

static Symbol table[MAX];
static int    count = 0;

static int find(const char *name)
{
    if (name == NULL)
        return -1;

    for (int i = 0; i < count; i++) {
        if (strcmp(table[i].name, name) == 0)
            return i;
    }
    return -1;
}

void declare(char *name, int ligne)
{
    if (name == NULL)
        return;

    if (find(name) != -1) {
        fprintf(stderr,
                "Erreur Semantique\nLigne : %d\nVariable : '%s'\n"
                "Probleme : Variable deja declaree\n"
                "Hint : Chaque variable ne peut etre declaree qu'une seule fois.\n",
                ligne, name);
        nb_erreurs++;
        return;
    }

    if (count >= MAX) {
        fprintf(stderr,
                "Erreur Semantique\nLigne : %d\n"
                "Probleme : Table des symboles pleine (maximum %d variables)\n",
                ligne, MAX);
        nb_erreurs++;
        return;
    }

    strncpy(table[count].name, name, sizeof(table[count].name) - 1);
    table[count].name[sizeof(table[count].name) - 1] = '\0';
    strncpy(table[count].type, "int", sizeof(table[count].type) - 1);
    table[count].type[sizeof(table[count].type) - 1] = '\0';
    table[count].value = 0;
    count++;
}

int lookup(char *name, int ligne)
{
    int index = find(name);

    if (index == -1) {
        fprintf(stderr,
                "Erreur Semantique\nLigne : %d\nVariable : '%s'\n"
                "Probleme : Variable non declaree\n"
                "Hint : Declarez la variable avec 'int %s' avant de l'utiliser.\n",
                ligne, name ? name : "(null)", name ? name : "(null)");
        nb_erreurs++;
        return 0;
    }

    return table[index].value;
}

void set_value(char *name, int val, int ligne)
{
    int index = find(name);

    if (index == -1) {
        fprintf(stderr,
                "Erreur Semantique\nLigne : %d\nVariable : '%s'\n"
                "Probleme : Variable non declaree\n"
                "Hint : Declarez la variable avec 'int %s' avant de l'utiliser.\n",
                ligne, name ? name : "(null)", name ? name : "(null)");
        nb_erreurs++;
        return;
    }

    table[index].value = val;
}

/* Affiche toutes les variables et leur valeur (debogage). */
void afficherTabSym(void)
{
    for (int i = 0; i < count; i++)
        printf("%s %d\n", table[i].name, table[i].value);
}
