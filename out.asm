# out.asm — gerado a partir do test.ham
OPEN_TABLE 1
ORDER mesa1 hamburguer
ORDER mesa1 bebida
PRINT_STR "Pedidos adicionados"

; if mesa1 == aberta then { entregar_proximo; } else { print("Mesa fechada"); }
JZ mesa_mesa1_aberta else_1
DELIVER
GOTO end_if_1
else_1:
PRINT_STR "Mesa fechada"
end_if_1:

; while fila not empty { entregar_proximo; }
start_while_1:
JZ fila_not_empty end_while_1
DELIVER
GOTO start_while_1
end_while_1:

PAY mesa1
PRINT_STR "Fim do expediente"
HALT
