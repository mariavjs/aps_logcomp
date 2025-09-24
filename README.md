# HamburgueriaVM


Feito por: Maria Vitoria Jardim Sartori


# Entrega 1 - 24/09

A ideia é que esta linguagem simule o funcionamento simples de uma hamburgueria. A ideia é representar mesas que fazem pedidos, uma fila global que armazena pedidos pendentes e o estado de fechamento da mesa por meio da efetuação do pagamento. 

# Elementos
Cada pedido pode conter items pré-definidos: hamburguer, bebida e batata. 
Cada mesa pode estaar em dois estados: aberta ou paga;
Fila de pedidos é a fila na qual estarão os pedidos pendentes até serem entregues. 
 
Para tal, será necessário utilizar de 2 registradores:
R1: Fila (número de pedidos pendentes)
R2: Estado da mesa (aberta ou paga)

# Comandos 
abrir_mesa(n); → abre mesa n

fazer_pedido(mesa, item); → adiciona item na fila.

pagar(mesa); → fecha a conta da mesa.

entregar_proximo(); → processa o próximo pedido da fila.

print(...); → exibe mensagens.


# EBNF

'''

        PROGRAM      = { STATEMENT } ;

        STATEMENT    = COMMAND | CONDITIONAL | LOOP | PRINT ;

        COMMAND      = ABRIR_MESA | FAZER_PEDIDO | PAGAR | ENTREGAR ;

        ABRIR_MESA   = "abrir_mesa", "(", NUMBER, ")", ";" ;
        FAZER_PEDIDO = "fazer_pedido", "(", IDENTIFIER, ",", ITEM, ")", ";" ;
        PAGAR        = "pagar", "(", IDENTIFIER, ")", ";" ;
        ENTREGAR     = "entregar_proximo", ";" ;

        ITEM         = "hamburguer" | "batata" | "bebida" ;

        CONDITIONAL  = "if", CONDITION, "then", "{", { STATEMENT }, "}",
                    [ "else", "{", { STATEMENT }, "}" ] ;

        LOOP         = "while", CONDITION, "{", { STATEMENT }, "}" ;

        CONDITION    = IDENTIFIER, COMPARATOR, VALUE
                    | IDENTIFIER, "==", ("aberta" | "paga")
                    | "fila", "not", "empty" ;

        PRINT        = "print", "(", (STRING | IDENTIFIER), ")", ";" ;

        VALUE        = NUMBER | IDENTIFIER ;
        IDENTIFIER   = LETTER, { LETTER | DIGIT } ;
        NUMBER       = DIGIT, { DIGIT } ;
        STRING       = '"', { ANY_CHARACTER }, '"' ;

        COMPARATOR   = "==" | "!=" | "<" | ">" | "<=" | ">=" ;

        LETTER       = "a" | "b" | ... | "z" | "A" | "B" | ... | "Z" ;
        DIGIT        = "0" | "1" | ... | "9" ;



