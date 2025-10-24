%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;
extern FILE *yyin;

void yyerror(const char *s);
%}

%union {
    int num;
    char *str;
}

%token ABRIR_MESA FAZER_PEDIDO PAGAR ENTREGAR PRINT
%token IF THEN ELSE WHILE FILA NOT EMPTY
%token ABERTA PAGA
%token EQ NE LT GT LE GE
%token <str> IDENTIFIER STRING ITEM
%token <num> NUMBER

%type <str> value

%%

program:
    /* empty */
    | program statement
    ;

statement:
    command
    | conditional
    | loop
    | print_stmt
    ;

command:
    abrir_mesa
    | fazer_pedido
    | pagar
    | entregar
    ;

abrir_mesa:
    ABRIR_MESA '(' NUMBER ')' ';' {
        printf("Comando reconhecido: abrir_mesa(%d)\n", $3);
    }
    ;

fazer_pedido:
    FAZER_PEDIDO '(' IDENTIFIER ',' ITEM ')' ';' {
        printf("Comando reconhecido: fazer_pedido(%s, %s)\n", $3, $5);
        free($3);
        free($5);
    }
    ;

pagar:
    PAGAR '(' IDENTIFIER ')' ';' {
        printf("Comando reconhecido: pagar(%s)\n", $3);
        free($3);
    }
    ;

entregar:
    ENTREGAR ';' {
        printf("Comando reconhecido: entregar_proximo\n");
    }
    ;

print_stmt:
    PRINT '(' STRING ')' ';' {
        printf("Comando reconhecido: print(%s)\n", $3);
        free($3);
    }
    | PRINT '(' IDENTIFIER ')' ';' {
        printf("Comando reconhecido: print(%s)\n", $3);
        free($3);
    }
    ;

conditional:
    IF condition THEN '{' statement_list '}' {
        printf("Estrutura condicional reconhecida (if)\n");
    }
    | IF condition THEN '{' statement_list '}' ELSE '{' statement_list '}' {
        printf("Estrutura condicional reconhecida (if-else)\n");
    }
    ;

loop:
    WHILE condition '{' statement_list '}' {
        printf("Estrutura de repetição reconhecida (while)\n");
    }
    ;

statement_list:
    /* empty */
    | statement_list statement
    ;

condition:
    IDENTIFIER comparator value {
        printf("Condição: %s comparator %s\n", $1, $3);
        free($1);
        free($3);
    }
    | IDENTIFIER EQ ABERTA {
        printf("Condição: %s == aberta\n", $1);
        free($1);
    }
    | IDENTIFIER EQ PAGA {
        printf("Condição: %s == paga\n", $1);
        free($1);
    }
    | FILA NOT EMPTY {
        printf("Condição: fila not empty\n");
    }
    ;

comparator:
    EQ | NE | LT | GT | LE | GE
    ;

value:
    NUMBER {
        char buffer[20];
        sprintf(buffer, "%d", $1);
        $$ = strdup(buffer);
    }
    | IDENTIFIER {
        $$ = $1;
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático na linha %d: %s\n", yylineno, s);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror("Erro ao abrir arquivo");
            return 1;
        }
        yyin = file;
    }

    printf("=== Iniciando análise léxica e sintática ===\n\n");
    
    int result = yyparse();
    
    if (result == 0) {
        printf("\n=== Análise concluída com sucesso! ===\n");
    } else {
        printf("\n=== Análise falhou! ===\n");
    }

    return result;
}