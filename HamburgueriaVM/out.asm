OPEN_TABLE 1
ORDER mesa1 hamburguer
ORDER mesa1 bebida
PRINT_STR "Pedidos adicionados"
JZ mesa_mesa1_aberta else_0
DELIVER
GOTO end_if_1
else_0:
PRINT_STR "Mesa fechada"
end_if_1:
while_start_2:
JZ fila_not_empty while_end_3
DELIVER
GOTO while_start_2
while_end_3:
PAY mesa1
