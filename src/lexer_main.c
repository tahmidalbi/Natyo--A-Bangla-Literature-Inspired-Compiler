#include <stdio.h>
#include <stdlib.h>

extern FILE *yyin;
int yylex(void);

int main(int argc, char *argv[]) {
    int token;

    if (argc != 2) {
        printf("Usage: ./lexer_app.exe <input_file>\n");
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Error opening input file");
        return 1;
    }

    printf("Starting lexical analysis...\n\n");

    while ((token = yylex()) != 0) {
        /* token printing already happens inside lexer.l */
    }

    printf("\nLexical analysis finished.\n");

    fclose(yyin);
    return 0;
}