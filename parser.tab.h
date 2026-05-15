<<<<<<< HEAD
/* A Bison parser, made by GNU Bison 2.7.  */

/* Bison interface for Yacc-like parsers in C
   
      Copyright (C) 1984, 1989-1990, 2000-2012 Free Software Foundation, Inc.
   
=======
/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

>>>>>>> c98a4debc03c9cc71778ee0f0eabff8ad064f723
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     BEGIN_T = 258,
     END = 259,
     INT = 260,
     WRITE = 261,
     READ = 262,
     WHILE = 263,
     DO = 264,
     OD = 265,
     IF = 266,
     THEN = 267,
     ELSE = 268,
     FI = 269,
     FOR = 270,
     TO = 271,
     DONE = 272,
     LPAREN = 273,
     RPAREN = 274,
     ASSIGN = 275,
     GT = 276,
     LT = 277,
     GE = 278,
     LE = 279,
     NE = 280,
     EQ = 281,
     SEQ = 282,
     PLUS = 283,
     MINUS = 284,
     MUL = 285,
     DIV = 286,
     MOD = 287,
     POW = 288,
     NUM = 289,
     ID = 290
   };
#endif


#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{
<<<<<<< HEAD
/* Line 2058 of yacc.c  */
#line 52 "parser.y"
=======
#line 55 "parser.y"
>>>>>>> c98a4debc03c9cc71778ee0f0eabff8ad064f723

    int num;     //les nombres     
    char *str;  //les chaines


/* Line 2058 of yacc.c  */
#line 98 "parser.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;

<<<<<<< HEAD
#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
=======

>>>>>>> c98a4debc03c9cc71778ee0f0eabff8ad064f723
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */


#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
