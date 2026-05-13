module Main

import IO;
import ParseTree;
import Syntax;
import AST;
import Checker;

public void main() {
    loc file = |project://proyecto3/src/main/rascal/ejemplo.vl|;
    Tree pt = parse(#start[Program], file);
    println("[OK] Parse exitoso");
    Program ast = implode(#Program, pt);
    println("[OK] AST construido");
    println("\n=== Resultado ===");
    println(ast);

    println("\n=== Verificando tipos ===");
    TModel tm = veriLangTModel(pt);
    if (tm.messages == {}) {
        println("[OK] No se encontraron errores de tipos");
    } else {
        println("[ERRORES] Problemas encontrados:");
        for (msg <- tm.messages) {
            println("  - <msg>");
        }
    }
}