module Main

import IO;
import ParseTree;
import Syntax;
import AST;
import Checker;
import List;

public void main(loc file) {
    Tree pt = parse(#start[Program], file);
    println("[OK] Parse exitoso");
    Program ast = implode(#Program, pt);
    println("[OK] AST construido");
    println("\n=== Resultado ===");
    println(ast);

    println("\n=== Verificando tipos ===");
    TModel tm = veriLangTModel(pt);
    if (isEmpty(tm.messages)) {
        println("[OK] No se encontraron errores de tipos");
    } else {
        println("[ERRORES] Problemas encontrados:");
        for (msg <- tm.messages) {
            println("  - <msg>");
        }
    }
}