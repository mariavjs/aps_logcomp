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



### Análise Léxica e Sintática Implementadas

Esta entrega implementa:
- **Análise Léxica** usando Flex (`lexer.l`)
- **Análise Sintática** usando Bison (`parser.y`)
- **Makefile** para compilação automatizada
- **Arquivo de teste** (`test.ham`) demonstrando todas as funcionalidades

---

## Como Compilar e Executar

### Pré-requisitos

Instale Flex e Bison no seu sistema:

**Ubuntu/Debian:**
```bash
sudo apt-get install flex bison
```

**MacOS:**
```bash
brew install flex bison
```

**Fedora:**
```bash
sudo dnf install flex bison
```

### Compilação

No diretório do projeto, execute:

```bash
make
```

Isso irá:
1. Gerar o parser com Bison (`parser.tab.c` e `parser.tab.h`)
2. Gerar o lexer com Flex (`lex.yy.c`)
3. Compilar tudo e criar o executável `parser`

### Executar com arquivo de teste

```bash
make test
```

ou diretamente:

```bash
./parser test.ham
```

### Limpeza dos arquivos gerados

```bash
make clean
```

---

## Comandos da Linguagem

| Comando | Sintaxe | Descrição |
|---------|---------|-----------|
| **Abrir Mesa** | `abrir_mesa(n);` | Abre a mesa de número n |
| **Fazer Pedido** | `fazer_pedido(mesa, item);` | Adiciona um item na fila de pedidos |
| **Pagar** | `pagar(mesa);` | Fecha a conta da mesa |
| **Entregar** | `entregar_proximo;` | Processa e entrega o próximo pedido da fila |
| **Print** | `print("mensagem");` | Exibe uma mensagem ou valor de variável |

### Itens Disponíveis
- `hamburguer`
- `batata`
- `bebida`

---

## Estruturas de Controle

### Condicional (if-then-else)

```
if mesa1 == aberta then {
    pagar(mesa1);
    print("Mesa 1 foi paga!");
}

if mesa2 == paga then {
    print("Mesa 2 já está paga!");
} else {
    pagar(mesa2);
    print("Pagando mesa 2 agora!");
}
```

### Loop (while)

```
while fila not empty {
    entregar_proximo;
    print("Pedido entregue!");
}
```

### Condições Suportadas

- Comparações: `==`, `!=`, `<`, `>`, `<=`, `>=`
- Estado da mesa: `mesa1 == aberta`, `mesa2 == paga`
- Verificação de fila: `fila not empty`

---

## EBNF Completa

```ebnf
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
IDENTIFIER   = LETTER, { LETTER | DIGIT | "_" } ;
NUMBER       = DIGIT, { DIGIT } ;
STRING       = '"', { ANY_CHARACTER }, '"' ;

COMPARATOR   = "==" | "!=" | "<" | ">" | "<=" | ">=" ;

LETTER       = "a" | ... | "z" | "A" | ... | "Z" ;
DIGIT        = "0" | ... | "9" ;
```

---

## Exemplo Completo de Uso

```
// Programa de exemplo da HamburgueriaVM

// Abrindo mesas
abrir_mesa(1);
abrir_mesa(2);
abrir_mesa(3);

// Fazendo pedidos
fazer_pedido(mesa1, hamburguer);
fazer_pedido(mesa1, batata);
fazer_pedido(mesa2, bebida);
fazer_pedido(mesa3, hamburguer);

print("Pedidos realizados com sucesso!");

// Entregando pedidos enquanto houver itens na fila
while fila not empty {
    entregar_proximo;
    print("Pedido entregue!");
}

// Verificando estado das mesas e processando pagamentos
if mesa1 == aberta then {
    pagar(mesa1);
    print("Mesa 1 paga!");
}

if mesa2 == paga then {
    print("Mesa 2 já foi paga!");
} else {
    pagar(mesa2);
    print("Mesa 2 paga agora!");
}

print("Fim do expediente!");
```

---

## Saída Esperada

Ao executar o arquivo de teste, você verá:

```
=== Iniciando análise léxica e sintática ===

Comando reconhecido: abrir_mesa(1)
Comando reconhecido: abrir_mesa(2)
Comando reconhecido: abrir_mesa(3)
Comando reconhecido: fazer_pedido(mesa1, hamburguer)
Comando reconhecido: fazer_pedido(mesa1, batata)
Comando reconhecido: fazer_pedido(mesa2, bebida)
Comando reconhecido: fazer_pedido(mesa3, hamburguer)
Comando reconhecido: print("Pedidos realizados!")
Condição: fila not empty
Comando reconhecido: entregar_proximo
Comando reconhecido: print("Pedido entregue!")
Estrutura de repetição reconhecida (while)
Condição: mesa1 == aberta
Comando reconhecido: pagar(mesa1)
Comando reconhecido: print("Mesa 1 paga!")
Estrutura condicional reconhecida (if)
Condição: mesa2 == paga
Comando reconhecido: print("Mesa 2 já foi paga!")
Comando reconhecido: pagar(mesa2)
Comando reconhecido: print("Mesa 2 paga agora!")
Estrutura condicional reconhecida (if-else)
Comando reconhecido: print("Fim do expediente!")

=== Análise concluída com sucesso! ===
```

---

## Estrutura do Projeto

```
HamburgueriaVM/
├── lexer.l          # Análise Léxica (Flex)
├── parser.y         # Análise Sintática (Bison)
├── Makefile         # Automação da compilação
├── test.ham         # Arquivo de teste da linguagem
├── README.md        # Esta documentação
├── parser           # Executável gerado (após make)
├── parser.tab.c     # Gerado pelo Bison
├── parser.tab.h     # Gerado pelo Bison
└── lex.yy.c         # Gerado pelo Flex
```

---
