module Syntax

layout Layout = WhitespaceAndComment* !>> [\ \t\n\r];
lexical WhitespaceAndComment = [\ \t\n\r];

lexical ID = ([a-zA-Z][a-zA-Z0-9\-]* !>> [a-zA-Z0-9\-]) \ Reserved;

lexical IntegerLit = [0-9]+ !>> [0-9];
lexical BooleanLit = "true" | "false";
lexical CharLit    = "\'" [a-zA-Z0-9] "\'";
lexical StringLit  = "\"" ![\"]* "\"";

keyword Reserved = 
    "defmodule" | "using" | "defspace" | "defoperator" |
    "defexpression" | "defrule" | "end" | 
    "forall" | "exists" | "defer" | "in" | "defvar" |
    "defstruct" | "Integer" | "Boolean" | "Char" | "String" |
    "true" | "false";

start syntax Program = program: ModuleDef moduleDef;

syntax Import = imp: 'using' ID name;

syntax ModuleDef = @category="keyword" moduleDef: 'defmodule' ID name Import* ModuleBodyItem* 'end';

syntax ModuleBodyItem = 
    spaceDefItem: SpaceDef spaceDef
  | operatorDefItem: OperatorDef operatorDef
  | expressionDefItem: ExpressionDef expressionDef
  | ruleDefItem: RuleDef ruleDef
  | variableDefItem: VariableDef variableDef
  | structDefItem: StructDef structDef;

syntax SpaceDef = @category="keyword" spaceDef: 'defspace' ID name SpaceParent parent 'end';

syntax SpaceParent
  = parent: '\<' ID name
  | noParent: ;

syntax TypeSig = typeSig: TypeAtom first TypeSigTail* rest;

syntax TypeSigTail = typeSigTail: '-\>' TypeAtom atom;

syntax TypeAtom = typeAtom: Type typeVal;

syntax Attributes = attributes: '[' {Attribute ','}+ ']';

syntax OperatorDef = @category="keyword" operatorDef: 'defoperator' ID name ':' TypeSig typeSig Attributes? 'end';

syntax Attribute
  = attributeWithValue: ID name ':' (ID | '∅') value
  | attributeNoValue:   ID name;

syntax VariableDef = variableDef: 'defvar' VarBinding+ 'end';

syntax VarBinding = varBinding: ID name ':' Type type;

syntax RuleDef = ruleDef: 'defrule' OperatorApp left '-\>' OperatorApp right 'end';

syntax OperatorApp = operatorApp: '(' ID Term* ')';

syntax Term = termId: ID | termEmpty: '∅';

syntax ExpressionDef = expressionDef: 'defexpression' Expr expr Attributes? 'end';

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

// ─── Punto 4: Tipos y estructuras de datos ─────────────────────────────────

syntax Type
  = intType:  'Integer'
  | boolType: 'Boolean'
  | charType: 'Char'
  | strType:  'String'
  | userType: ID name;

syntax TypedValue
  = intVal:  IntegerLit val ':' 'Integer'
  | boolVal: BooleanLit val ':' 'Boolean'
  | charVal: CharLit val ':' 'Char'
  | strVal:  StringLit val ':' 'String';

syntax StructDef = structDef: 'defstruct' ID name ':' Type structType TypedValue* values 'end';
