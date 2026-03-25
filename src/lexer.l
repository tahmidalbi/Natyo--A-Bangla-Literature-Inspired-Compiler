%option noyywrap
%option yylineno

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"
%}

LETTER      [A-Za-z_]
DIGIT       [0-9]
ID          {LETTER}({LETTER}|{DIGIT})*
INTNUM      {DIGIT}+
FLOATNUM    {DIGIT}+"."{DIGIT}+
STRINGLIT   \"([^\\\n]|(\\.))*\"
CHARLIT     \'([^\\\n]|(\\.))\'

%%

"$$".*                      { /* ignore single-line comment */ }

"$*"                        {
                                int prev = 0, curr;
                                while ((curr = input()) != 0) {
                                    if (prev == '*' && curr == '$') break;
                                    prev = curr;
                                }
                                if (curr == 0) {
                                    fprintf(stderr, "Lexical Error: Unclosed multi-line comment at line %d\n", yylineno);
                                }
                            }

"prostabona"                { return PROSTABONA; }
"uposhonghar"               { return UPOSHONGHAR; }
"drissho"                   { return DRISSHO; }
"shuru"                     { return SHURU; }
"shesh"                     { return SHESH; }
"shonkhya"                  { return SHONKHYA; }
"purnoshonkhya"             { return PURNOSHONKHYA; }
"bakkyo"                    { return BAKKYO; }
"okkhyor"                   { return OKKHYOR; }
"shobdo"                    { return SHOBDO; }
"jobdo"                     { return JOBDO; }
"jodi"                      { return JODI; }
"onnotha"                   { return ONNOTHA; }
"chokro"                    { return CHOKRO; }
"shakti"                    { return SHAKTI; }
"borgomul"                  { return BORGOMUL; }
"pherot"                    { return PHEROT; }

{STRINGLIT}                 {
                                int len = strlen(yytext);
                                char *tmp = (char *)malloc(len - 1);
                                strncpy(tmp, yytext + 1, len - 2);
                                tmp[len - 2] = '\0';
                                yylval.sval = tmp;
                                return STRING_LITERAL;
                            }

{CHARLIT}                   {
                                yylval.cval = yytext[1];
                                return CHAR_LITERAL;
                            }

{FLOATNUM}                  {
                                yylval.fval = atof(yytext);
                                return FLOAT_LITERAL;
                            }

{INTNUM}                    {
                                yylval.ival = atoi(yytext);
                                return INT_LITERAL;
                            }

">="                        { return GEQ; }
"<="                        { return LEQ; }
"=="                        { return EQ; }
"!="                        { return NEQ; }
">"                         { return GT; }
"<"                         { return LT; }
"="                         { return ASSIGN; }
"+"                         { return PLUS; }
"-"                         { return MINUS; }
"*"                         { return MULT; }
"/"                         { return DIV; }
"%"                         { return MOD; }

";"                         { return SEMICOLON; }
","                         { return COMMA; }
"("                         { return LPAREN; }
")"                         { return RPAREN; }

"PAI"                       {
                                yylval.sval = strdup(yytext);
                                return IDENTIFIER;
                            }

"E"                         {
                                yylval.sval = strdup(yytext);
                                return IDENTIFIER;
                            }

"G"                         {
                                yylval.sval = strdup(yytext);
                                return IDENTIFIER;
                            }

{ID}                        {
                                yylval.sval = strdup(yytext);
                                return IDENTIFIER;
                            }

[ \t\r\n]+                  { /* ignore whitespace */ }

.                           {
                                fprintf(stderr,
                                        "Lexical Error: Invalid token '%s' at line %d\n",
                                        yytext, yylineno);
                            }

%%