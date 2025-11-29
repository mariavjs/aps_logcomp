%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;
extern FILE *yyin;

void yyerror(const char *s);

/* output assembly file */
FILE *out;

/* label generation */
static int label_count = 0;
static char *new_label(const char *prefix) {
    char *buf = malloc(64);
    sprintf(buf, "%s_%d", prefix, label_count++);
    return buf;
}

/* stacks for nested conditionals/loops */
#define MAX_LABEL_DEPTH 1024
static char *else_stack[MAX_LABEL_DEPTH];
static char *end_stack[MAX_LABEL_DEPTH];
static int stack_sp = 0;

/* helper to push labels */
static void push_labels(char *else_lbl, char *end_lbl) {
    if (stack_sp >= MAX_LABEL_DEPTH) { fprintf(stderr,"Label stack overflow\n"); exit(1); }
    else_stack[stack_sp] = else_lbl;
    end_stack[stack_sp] = end_lbl;
    stack_sp++;
}

/* helper to peek/pop */
static char *peek_else_label() { return (stack_sp>0) ? else_stack[stack_sp-1] : NULL; }
static char *peek_end_label()  { return (stack_sp>0) ? end_stack[stack_sp-1] : NULL; }
static void pop_labels() { if (stack_sp>0) { free(else_stack[stack_sp-1]); free(end_stack[stack_sp-1]); stack_sp--; } }

%}

%union {
    int num;
    char *str;
}

/* tokens */
%token ABRIR_MESA FAZER_PEDIDO PAGAR ENTREGAR PRINT
%token IF THEN ELSE WHILE FILA NOT EMPTY
%token ABERTA PAGA
%token EQ NE LT GT LE GE
%token <str> IDENTIFIER STRING ITEM
%token <num> NUMBER

/* types */
%type <str> value
%type <str> condition

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
        /* emit assembly */
        fprintf(out, "OPEN_TABLE %d\n", $3);
    }
    ;

fazer_pedido:
    FAZER_PEDIDO '(' IDENTIFIER ',' ITEM ')' ';' {
        fprintf(out, "ORDER %s %s\n", $3, $5);
        free($3);
        free($5);
    }
    ;

pagar:
    PAGAR '(' IDENTIFIER ')' ';' {
        fprintf(out, "PAY %s\n", $3);
        free($3);
    }
    ;

entregar:
    ENTREGAR ';' {
        fprintf(out, "DELIVER\n");
    }
    ;

print_stmt:
    PRINT '(' STRING ')' ';' {
        /* keep quotes in the emitted assembly so VM can strip them */
        fprintf(out, "PRINT_STR %s\n", $3);
        free($3);
    }
    | PRINT '(' IDENTIFIER ')' ';' {
        fprintf(out, "PRINT_VAR %s\n", $3);
        free($3);
    }
    ;

/* CONDITIONAL
   We use mid-rule actions to:
   - after reading condition, create labels and emit JZ <pred> <else_lbl>
   - after the true-block, emit GOTO <end_lbl> and the else label
   - then either emit else statements and finally emit end label
*/
conditional:
    IF condition
        {
            /* after condition reduced, $2 contains predicate string (owned) */
            char *else_lbl = new_label("else");
            char *end_lbl  = new_label("end_if");
            /* push them to stack for later emissions */
            push_labels(else_lbl, end_lbl);
            /* emit conditional jump to else */
            fprintf(out, "JZ %s %s\n", $2, else_lbl);
            free($2); /* condition produced a malloc'd string */
        }
    THEN '{' statement_list '}' 
        {
            /* finished true block: emit jump to end and else label */
            char *else_lbl = peek_else_label();
            char *end_lbl  = peek_end_label();
            if (!else_lbl || !end_lbl) { fprintf(stderr,"Internal error: labels missing in if\n"); exit(1); }
            fprintf(out, "GOTO %s\n", end_lbl);
            fprintf(out, "%s:\n", else_lbl);
            /* don't pop yet; optional_else will finalize (and pop) */
        }
    optional_else
    ;

optional_else:
    /* no else */
    {
        /* no else statements: emit end label and pop labels */
        char *end_lbl = peek_end_label();
        if (!end_lbl) { fprintf(stderr,"Internal error: end label missing (no else)\n"); exit(1); }
        fprintf(out, "%s:\n", end_lbl);
        pop_labels();
    }
    | ELSE '{' statement_list '}' 
    {
        /* else block parsed; now emit end label and pop */
        char *end_lbl = peek_end_label();
        if (!end_lbl) { fprintf(stderr,"Internal error: end label missing (with else)\n"); exit(1); }
        fprintf(out, "%s:\n", end_lbl);
        pop_labels();
    }
    ;

/* LOOP (while)
   Structure: create start and end labels. Emit start_label: then after condition emit JZ predicate end_label.
   After body, emit GOTO start_label and then end_label:
*/
loop:
    {
        /* create and emit the start label before the WHILE condition */
        char *start_lbl = new_label("while_start");
        char *end_lbl   = new_label("while_end");
        /* push these onto stack (reuse same stacks; we'll treat them similarly) */
        push_labels(start_lbl, end_lbl);
        /* emit start label immediately */
        fprintf(out, "%s:\n", start_lbl);
    }
    WHILE condition
    {
        /* after condition: emit JZ pred end_label */
        char *end_lbl = peek_end_label();
        if (!end_lbl) { fprintf(stderr,"Internal error: end label missing in while\n"); exit(1); }
        /* $2 is condition string */
        fprintf(out, "JZ %s %s\n", $3, end_lbl);
        free($3);
    }
    '{' statement_list '}' 
    {
        /* after body: emit jump back to start, then end label; then pop */
        char *start_lbl = peek_else_label(); /* we stored start in else_stack position */
        char *end_lbl   = peek_end_label();
        if (!start_lbl || !end_lbl) { fprintf(stderr,"Internal error: labels missing in while end\n"); exit(1); }
        fprintf(out, "GOTO %s\n", start_lbl);
        fprintf(out, "%s:\n", end_lbl);
        pop_labels();
    }
    ;

/* statement_list: just a sequence of statements (their actions already emitted assembly) */
statement_list:
    /* empty */
    | statement_list statement
    ;

/* CONDITION: produce a string (allocated) representing predicate recognized by VM
   Supported predicates:
     - FILA NOT EMPTY   -> "fila_not_empty"
     - IDENTIFIER == ABERTA -> "mesa_<identifier>_aberta"
     - IDENTIFIER == PAGA   -> "mesa_<identifier>_paga"
   For other comparators we emit a conservative placeholder (fila_not_empty) and warn.
*/
condition:
    IDENTIFIER EQ ABERTA {
        /* $1 is identifier string like mesa1 or mesaX */
        char *pred = malloc(128);
        sprintf(pred, "mesa_%s_aberta", $1);
        $$ = pred;
        free($1);
    }
    | IDENTIFIER EQ PAGA {
        char *pred = malloc(128);
        sprintf(pred, "mesa_%s_paga", $1);
        $$ = pred;
        free($1);
    }
    | FILA NOT EMPTY {
        $$ = strdup("fila_not_empty");
    }
    | IDENTIFIER comparator value {
        /* comparator with arbitrary value not directly supported by VM predicate;
           emit a fallback and warn in stderr. */
        fprintf(stderr, "Warning: comparator condition (%s ... %s) not directly supported, using 'fila_not_empty' fallback\n", $1, $3);
        $$ = strdup("fila_not_empty");
        free($1);
        free($3);
    }
    ;

/* comparator (not used for codegen here, kept for completeness) */
comparator:
    EQ | NE | LT | GT | LE | GE
    ;

/* value: return a string representation (number or identifier) */
value:
    NUMBER {
        char buffer[32];
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

    /* open out.asm for writing assembly emitted by parser */
    out = fopen("out.asm", "w");
    if (!out) {
        perror("Erro ao criar out.asm");
        return 1;
    }

    printf("=== Iniciando análise léxica e sintática ===\n\n");
    
    int result = yyparse();

    fclose(out);
    
    if (result == 0) {
        printf("\n=== Análise concluída com sucesso! (out.asm gerado) ===\n");
    } else {
        printf("\n=== Análise falhou! ===\n");
    }

    return result;
}
