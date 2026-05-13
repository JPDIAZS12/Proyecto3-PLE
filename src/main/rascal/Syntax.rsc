module Syntax

layout Layout = WhitespaceAndComment* !>> [\ \t\n\r];
lexical WhitespaceAndComment = [\ \t\n\r];

// Arrow y LAngle eliminados — se usan literales directamente

lexical ID = ([a-zA-Z][a-zA-Z0-9\-]* !>> [a-zA-Z0-9\-]) \ Reserved;

keyword Reserved = 
    "defmodule" | "using" | "defspace" | "defoperator" |
    "defexpression" | "defrule" | "end" | 
    "forall" | "exists" | "defer" | "in" | "defvar";

start syntax Program = program: ModuleDef moduleDef;

syntax Import = imp: 'using' ID name;

syntax ModuleDef = @category="keyword" moduleDef: 'defmodule' ID name Import* ModuleBodyItem* 'end';

syntax ModuleBodyItem = 
    spaceDefItem: SpaceDef spaceDef
  | operatorDefItem: OperatorDef operatorDef
  | expressionDefItem: ExpressionDef expressionDef
  | ruleDefItem: RuleDef ruleDef
  | variableDefItem: VariableDef variableDef;

syntax SpaceDef = @category="keyword" spaceDef: 'defspace' ID name SpaceParent parent 'end';

// LAngle eliminado: se usa '<' literal directamente; str angle removido del AST
syntax SpaceParent
  = parent: '\<' ID name
  | noParent: ;

// Arrow eliminado: se usa '->' literal directamente
syntax TypeSig = typeSig: TypeAtom first TypeSigTail* rest;

syntax TypeSigTail = typeSigTail: '-\>' TypeAtom atom;

syntax TypeAtom = typeAtom: ID name;

syntax OperatorDef = @category="keyword" operatorDef: 'defoperator' ID name ':' TypeSig typeSig ('[' {Attribute ','}+ ']')? 'end';

syntax Attributes = attributes: '[' Attribute (',' Attribute)* ']';

// CORREGIDO: dos alternativas para que implode funcione con y sin valor
syntax Attribute
  = attributeWithValue: ID name ':' (ID | '∅') value
  | attributeNoValue:   ID name;

syntax VariableDef = variableDef: 'defvar' VarBinding+ 'end';

syntax VarBinding = varBinding: ID name ':' ID type;

// Arrow eliminado: se usa '->' literal directamente
syntax RuleDef = ruleDef: 'defrule' OperatorApp left '-\>' OperatorApp right 'end';

syntax OperatorApp = operatorApp: '(' ID Term* ')';

syntax Term = termId: ID | termEmpty: '∅';

syntax ExpressionDef = expressionDef: 'defexpression' Expr expr ('[' {Attribute ','}+ ']')? 'end';

syntax Expr
  = quantifiedExprNode: QuantifiedExpr quantifiedExpr
  | binaryExprNode: BinaryExpr binaryExpr
  | unaryExprNode: UnaryExpr unaryExpr
  | atomExprNode: AtomExpr atomExpr;

syntax QuantifiedExpr = quantifiedExpr: Quantifier ID name 'in' ID varName '.' Expr;

syntax Quantifier = forall: 'forall' | exists: 'exists' | defer: 'defer';

syntax BinaryExpr = binaryExpr: AtomExpr left BinaryOp op AtomExpr right;

syntax BinaryOp = 
    add: '+' | sub: '-' | mul: '*' | div: '/' 
  | pow: '**' | modulo: '%' | lt: '\<' | gt: '\>'
  | leq: '\<=' | geq: '\>=' | neq: '\<\>' | eq: '='
  | impl: '=\>' | equiv: '≡' | andOp: 'and' 
  | orOp: 'or' | inOp: 'in' | arrowOp: '-\>';

syntax UnaryExpr = unaryExpr: UnaryOp AtomExpr;

syntax UnaryOp = minus: '-' | neg: 'neg';

syntax AtomExpr
  = operatorAtom: OperatorApp operatorApp
  | idExpr: ID name
  | parenExpr: "(" Expr expr ")"
  | emptyExpr: "∅";
