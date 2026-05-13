module Main

import IO;
import ParseTree;
import Syntax;
import AST;

public void main(loc file) {
    Tree pt = parse(#start[Program], file);
    println("[OK] Parse exitoso");
    Program ast = implode(#Program, pt);
    println("[OK] AST construido");
    println("\n=== Resultado ===");
    println(ast);
}
