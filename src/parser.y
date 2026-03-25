%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int yylex(void);
void yyerror(const char *s);

extern FILE *yyin;
extern int yylineno;
%}

%union {
    int ival;
    double fval;
    char cval;
    char *sval;
}

/* Tokens with values */
%token <ival> INT_LITERAL
%token <fval> FLOAT_LITERAL
%token <cval> CHAR_LITERAL
%token <sval> STRING_LITERAL
%token <sval> IDENTIFIER

/* Keywords */
%token PROSTABONA UPOSHONGHAR
%token DRISSHO SHURU SHESH
%token SHONKHYA PURNOSHONKHYA BAKKYO OKKHYOR
%token SHOBDO JOBDO
%token JODI ONNOTHA CHOKRO
%token SHAKTI BORGOMUL
%token PHEROT

/* Operators / punctuation */
%token ASSIGN
%token PLUS MINUS MULT DIV MOD
%token GT LT GEQ LEQ EQ NEQ
%token SEMICOLON COMMA
%token LPAREN RPAREN

/* Precedence */
%nonassoc LOWER_THAN_ELSE
%nonassoc ONNOTHA
%left GT LT GEQ LEQ EQ NEQ
%left PLUS MINUS
%left MULT DIV MOD
%right UMINUS

%type <fval> expression
%type <ival> condition

%%

program
    : PROSTABONA global_items UPOSHONGHAR
      {
          printf("Syntax Analysis Successful: valid Natyo program.\n");
      }
    ;

global_items
    : /* empty */
    | global_items global_item
    ;

global_item
    : statement
    | function_definition
    ;

function_definition
    : DRISSHO IDENTIFIER LPAREN parameter_list_opt RPAREN block
    ;

parameter_list_opt
    : /* empty */
    | parameter_list
    ;

parameter_list
    : IDENTIFIER
    | parameter_list COMMA IDENTIFIER
    ;

block
    : SHURU statement_list SHESH
    ;

statement_list
    : /* empty */
    | statement_list statement
    ;

statement
    : declaration SEMICOLON
    | assignment SEMICOLON
    | print_stmt SEMICOLON
    | input_stmt SEMICOLON
    | function_call SEMICOLON
    | return_stmt SEMICOLON
    | if_stmt
    | loop_stmt
    | block
    ;

declaration
    : SHONKHYA numeric_declarator_list
    | PURNOSHONKHYA numeric_declarator_list
    | BAKKYO string_declarator_list
    | OKKHYOR char_declarator_list
    ;

numeric_declarator_list
    : numeric_declarator
    | numeric_declarator_list COMMA numeric_declarator
    ;

numeric_declarator
    : IDENTIFIER
    | IDENTIFIER ASSIGN expression
    ;

string_declarator_list
    : string_declarator
    | string_declarator_list COMMA string_declarator
    ;

string_declarator
    : IDENTIFIER
    | IDENTIFIER ASSIGN STRING_LITERAL
    ;

char_declarator_list
    : char_declarator
    | char_declarator_list COMMA char_declarator
    ;

char_declarator
    : IDENTIFIER
    | IDENTIFIER ASSIGN CHAR_LITERAL
    ;

assignment
    : IDENTIFIER ASSIGN expression
    | IDENTIFIER ASSIGN STRING_LITERAL
    | IDENTIFIER ASSIGN CHAR_LITERAL
    ;

print_stmt
    : SHOBDO printable
    ;

printable
    : expression
    | STRING_LITERAL
    | CHAR_LITERAL
    ;

input_stmt
    : JOBDO IDENTIFIER
    ;

return_stmt
    : PHEROT expression
    | PHEROT STRING_LITERAL
    | PHEROT CHAR_LITERAL
    ;

if_stmt
    : JODI LPAREN condition RPAREN statement %prec LOWER_THAN_ELSE
    | JODI LPAREN condition RPAREN statement ONNOTHA statement
    ;

loop_stmt
    : CHOKRO LPAREN assignment SEMICOLON condition SEMICOLON assignment RPAREN statement
    ;

function_call
    : IDENTIFIER LPAREN argument_list_opt RPAREN
    ;

argument_list_opt
    : /* empty */
    | argument_list
    ;

argument_list
    : argument
    | argument_list COMMA argument
    ;

argument
    : expression
    | STRING_LITERAL
    | CHAR_LITERAL
    ;

condition
    : expression GT expression   { $$ = ($1 > $3); }
    | expression LT expression   { $$ = ($1 < $3); }
    | expression GEQ expression  { $$ = ($1 >= $3); }
    | expression LEQ expression  { $$ = ($1 <= $3); }
    | expression EQ expression   { $$ = ($1 == $3); }
    | expression NEQ expression  { $$ = ($1 != $3); }
    ;

expression
    : expression PLUS expression    { $$ = $1 + $3; }
    | expression MINUS expression   { $$ = $1 - $3; }
    | expression MULT expression    { $$ = $1 * $3; }
    | expression DIV expression
      {
          if ($3 == 0) {
              yyerror("division by zero in expression");
              $$ = 0;
          } else {
              $$ = $1 / $3;
          }
      }
    | expression MOD expression     { $$ = (int)$1 % (int)$3; }
    | MINUS expression %prec UMINUS { $$ = -$2; }
    | LPAREN expression RPAREN      { $$ = $2; }
    | SHAKTI LPAREN expression COMMA expression RPAREN
      {
          $$ = pow($3, $5);
      }
    | BORGOMUL LPAREN expression RPAREN
      {
          if ($3 < 0) {
              yyerror("square root of negative number");
              $$ = 0;
          } else {
              $$ = sqrt($3);
          }
      }
    | function_call                 { $$ = 0; }
    | INT_LITERAL                   { $$ = (double)$1; }
    | FLOAT_LITERAL                 { $$ = $1; }
    | IDENTIFIER                    { $$ = 0; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error at line %d: %s\n", yylineno, s);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: natyo_parser.exe <input_file>\n");
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Could not open input file");
        return 1;
    }

    printf("Starting syntax analysis...\n");
    yyparse();
    fclose(yyin);
    return 0;
}