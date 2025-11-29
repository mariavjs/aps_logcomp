#!/usr/bin/env python3
# vm.py — HamburgueriaVM interpreter
# Uso: python3 vm.py out.asm

import sys
from collections import deque

class HamburgueriaVM:
    def __init__(self):
        self.queue = deque()       # pedidos pendentes: tuples (mesa, item)
        self.tables = {}           # mesa name -> "aberta"|"paga"
        self.vars = {}             # variáveis string -> valor (opcional)
        self.labels = {}           # label -> instruction index
        self.pc = 0
        self.instructions = []
        self.running = True
        self.debug = False

    def load(self, lines):
        # strip comments and blank lines
        instrs = []
        for raw in lines:
            line = raw.strip()
            if not line or line.startswith('#') or line.startswith(';'):
                continue
            instrs.append(line)
        # first pass: collect labels
        for i, line in enumerate(instrs):
            if line.endswith(':'):
                label = line[:-1].strip()
                self.labels[label] = i
        self.instructions = instrs

    def run(self, debug=False, step_limit=1000000):
        self.debug = debug
        self.pc = 0
        steps = 0
        while self.pc < len(self.instructions) and self.running:
            if steps >= step_limit:
                print("[VM] Step limit reached, aborting.")
                break
            line = self.instructions[self.pc].strip()
            self.pc += 1
            steps += 1

            # skip labels
            if line.endswith(':'):
                continue

            parts = line.split()
            op = parts[0].upper()

            if self.debug:
                print(f"[VM] PC={self.pc-1} OP={op} ARGS={parts[1:]}")

            try:
                if op == "OPEN_TABLE":
                    # OPEN_TABLE n
                    n = parts[1]
                    name = f"mesa{n}"
                    self.tables[name] = "aberta"
                    print(f"[VM] Mesa {n} aberta.")
                elif op == "ORDER":
                    # ORDER mesa item
                    mesa = parts[1]
                    item = parts[2]
                    self.queue.append((mesa, item))
                    print(f"[VM] Pedido enfileirado: {mesa} -> {item}")
                elif op == "PAY":
                    mesa = parts[1]
                    self.tables[mesa] = "paga"
                    print(f"[VM] Mesa {mesa} paga.")
                elif op == "DELIVER":
                    if self.queue:
                        mesa, item = self.queue.popleft()
                        print(f"[VM] Entregue {item} para {mesa}")
                    else:
                        print("[VM] Fila vazia - nada a entregar")
                elif op == "PRINT_STR":
                    # PRINT_STR <rest of line as string>
                    # the parser should escape and provide the string as a single token possibly with underscores replaced
                    s = line[len("PRINT_STR"):].strip()
                    # if string wrapped in quotes, remove
                    if s.startswith('"') and s.endswith('"'):
                        s = s[1:-1]
                    print(s)
                elif op == "PRINT_VAR":
                    name = parts[1]
                    print(self.vars.get(name, "(undef)"))
                elif op == "SET_VAR":
                    # SET_VAR name value
                    name = parts[1]
                    val = parts[2]
                    self.vars[name] = val
                elif op == "GOTO":
                    label = parts[1]
                    if label not in self.labels:
                        print(f"[VM] Erro: label '{label}' não encontrado.")
                        break
                    self.pc = self.labels[label] + 1
                elif op == "JZ":
                    # JZ var label  -> jump if var == 0 (var can be "fila_size" or mesa state predicate)
                    var = parts[1]
                    label = parts[2]
                    cond = False
                    if var == "fila_not_empty":
                        cond = (len(self.queue) > 0)
                    elif var.startswith("mesa_"): # mesa_mesa1_aberta ?
                        # parser will emit e.g. mesa_mesa1_aberta to check mesa1 == aberta
                        # format: mesa_<mesaName>_aberta  or mesa_<mesaName>_paga
                        toks = var.split('_')
                        # mesa_mesa1_aberta
                        if len(toks) >= 3:
                            mesa_name = toks[1]
                            wanted = toks[2]
                            val = self.tables.get(mesa_name, "paga")
                            cond = (val == wanted)
                    # JZ semantics: jump if NOT cond? We'll use: JZ var label -> if cond == false => jump
                    if not cond:
                        if label not in self.labels:
                            print(f"[VM] Erro: label '{label}' não encontrado.")
                            break
                        self.pc = self.labels[label] + 1
                elif op == "HALT":
                    self.running = False
                else:
                    print(f"[VM] Instr. desconhecida: {line}")
            except Exception as e:
                print(f"[VM] Erro execução: {e}")
                break

        if self.running:
            print("[VM] Execução terminada (pc >= len).")
        else:
            print("[VM] Execução parada (HALT).")

def load_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.readlines()

def main():
    if len(sys.argv) < 2:
        print("Uso: python3 vm.py out.asm")
        sys.exit(1)
    asm = load_file(sys.argv[1])
    vm = HamburgueriaVM()
    vm.load(asm)
    vm.run()

if __name__ == "__main__":
    main()
