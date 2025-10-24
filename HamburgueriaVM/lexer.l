%{
#include "parser.tab.h"
#include <string.h>
%}

%option noyywrap
%option yylineno
%option nounput
%option noinput

%%

"abrir_mesa"        { return ABRIR_MESA; }
"fazer_pedido"      { return FAZER_PEDIDO; }
"pagar"             { return PAGAR; }
"entregar_proximo"  { return ENTREGAR; }
"print"             { return PRINT; }
"if"                { return IF; }
"then"              { return THEN; }
"else"              { return ELSE; }
"while"             { return WHILE; }
"fila"              { return FILA; }
"not"               { return NOT; }
"empty"             { return EMPTY; }

"hamburguer"        { yylval.str = strdup(yytext); return ITEM; }
"batata"            { yylval.str = strdup(yytext); return ITEM; }
"bebida"            { yylval.str = strdup(yytext); return ITEM; }

"aberta"            { return ABERTA; }
"paga"              { return PAGA; }

"=="                { return EQ; }
"!="                { return NE; }
"<="                { return LE; }
">="                { return GE; }
"<"                 { return LT; }
">"                 { return GT; }

[a-zA-Z][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return IDENTIFIER; }
[0-9]+              { yylval.num = atoi(yytext); return NUMBER; }

\"([^\"\\]|\\.)*\"  { 
    yylval.str = strdup(yytext); 
    return STRING; 
}

"("                 { return '('; }
")"                 { return ')'; }
"{"                 { return '{'; }
"}"                 { return '}'; }
";"                 { return ';'; }
","                 { return ','; }

[ \t]+              { /* ignore whitespace */ }
\n                  { /* newline handled by yylineno */ }
"//".*              { /* ignore single-line comments */ }

.                   { printf("Erro léxico: caractere inválido '%s' na linha %d\n", yytext, yylineno); }

%%