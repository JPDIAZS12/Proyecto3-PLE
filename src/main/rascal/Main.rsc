module Main

import IO;
import ParseTree;
import Syntax;
import AST;
import Checker;
import List;
// Para correr este programa, abrir el REPL de Rascal y ejecutar:
// import Main;
// main(|file:///RUTA/AL/ARCHIVO/ejemplo.vl|);
// Ejemplo:
// main(|file:///C:/Users/TuUsuario/ruta/al/proyecto/src/main/rascal/ejemplo.vl|);

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