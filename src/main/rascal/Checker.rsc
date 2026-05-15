module Checker
extend analysis::typepal::TypePal;
import ParseTree;
import Syntax;

data AType
    = intType()
    | boolType()
    | charType()
    | strType()
    | userType(str name)
    | operatorType(AType from, AType to);

str prettyAType(intType())          = "Integer";
str prettyAType(boolType())         = "Boolean";
str prettyAType(charType())         = "Char";
str prettyAType(strType())          = "String";
str prettyAType(userType(str name)) = name;
str prettyAType(operatorType(AType from, AType to)) = "<prettyAType(from)> -\> <prettyAType(to)>";

data IdRole
    = spaceId()
    | operatorId()
    | variableId()
    | structId();

AType toAType((Type) `Integer`)     = intType();
AType toAType((Type) `Boolean`)     = boolType();
AType toAType((Type) `Char`)        = charType();
AType toAType((Type) `String`)      = strType();
AType toAType((Type) `<ID name>`)   = userType("<name>");

AType toAType((TypeAtom) `<Type t>`) = toAType(t);

AType toAType((TypeSigTail) `-\> <TypeAtom atom>`) = toAType(atom);

AType toAType((TypeSig) `<TypeAtom first> <TypeSigTail* rest>`) {
    AType result = toAType(first);
    for (t <- rest) result = operatorType(result, toAType(t));
    return result;
}

bool isPrimitive(intType())  = true;
bool isPrimitive(boolType()) = true;
bool isPrimitive(charType()) = true;
bool isPrimitive(strType())  = true;
bool isPrimitive(_)          = false;

void collect(current: (Program) `<ModuleDef md>`, Collector c) {
    collect(md, c);
}

void collect(current: (ModuleDef) `defmodule <ID _> <Import* imports> <ModuleBodyItem* items> end`, Collector c) {
    c.enterScope(current);
    collect(imports, c);
    collect(items, c);
    c.leaveScope(current);
}

void collect(current: (Import) `using <ID _>`, Collector c) { }

void collect(current: (ModuleBodyItem) `<SpaceDef sd>`, Collector c) { collect(sd, c); }

void collect(current: (SpaceDef) `defspace <ID name> <SpaceParent parent> end`, Collector c) {
    c.define("<name>", spaceId(), current, defType(userType("<name>")));
    collect(parent, c);
}

void collect(current: (SpaceParent) `\< <ID name>`, Collector c) {
    c.use(name, {spaceId()});
}

void collect(current: (SpaceParent) ``, Collector c) { }

void collect(current: (ModuleBodyItem) `<OperatorDef od>`, Collector c) { collect(od, c); }

void collect(current: (OperatorDef) `defoperator <ID name> : <TypeSig sig> <Attributes? _> end`, Collector c) {
    c.define("<name>", operatorId(), current, defType(toAType(sig)));
    collect(sig, c);
}

void collect(current: (TypeSig) `<TypeAtom first> <TypeSigTail* rest>`, Collector c) {
    collect(first, c);
    collect(rest, c);
}

void collect(current: (TypeAtom) `<Type t>`, Collector c) { collect(t, c); }

void collect(current: (TypeSigTail) `-\> <TypeAtom atom>`, Collector c) { collect(atom, c); }

void collect(current: (Type) `Integer`, Collector c) { c.fact(current, intType()); }
void collect(current: (Type) `Boolean`, Collector c) { c.fact(current, boolType()); }
void collect(current: (Type) `Char`,    Collector c) { c.fact(current, charType()); }
void collect(current: (Type) `String`,  Collector c) { c.fact(current, strType()); }
void collect(current: (Type) `<ID name>`, Collector c) {
    c.use(name, {spaceId()});
    c.fact(current, userType("<name>"));
}

void collect(current: (ModuleBodyItem) `<VariableDef vd>`, Collector c) { collect(vd, c); }

void collect(current: (VariableDef) `defvar <VarBinding+ bindings> end`, Collector c) {
    collect(bindings, c);
}

void collect(current: (VarBinding) `<ID name> : <Type t>`, Collector c) {
    c.define("<name>", variableId(), current, defType(toAType(t)));
    collect(t, c);
}

void collect(current: (ModuleBodyItem) `<RuleDef rd>`, Collector c) { collect(rd, c); }

void collect(current: (RuleDef) `defrule <OperatorApp left> -\> <OperatorApp right> end`, Collector c) {
    collect(left, c);
    collect(right, c);
}

void collect(current: (OperatorApp) `( <ID name> <Term* terms> )`, Collector c) {
    c.use(name, {operatorId()});
    collect(terms, c);
}

void collect(current: (Term) `<ID name>`, Collector c) {
    c.use(name, {variableId()});
}

void collect(current: (Term) `∅`, Collector c) { }

void collect(current: (ModuleBodyItem) `<ExpressionDef ed>`, Collector c) { collect(ed, c); }

void collect(current: (ExpressionDef) `defexpression <Expr expr> <Attributes? _> end`, Collector c) {
    collect(expr, c);
}

void collect(current: (Expr) `<QuantifiedExpr qe>`, Collector c) { collect(qe, c); }
void collect(current: (Expr) `<BinaryExpr be>`,     Collector c) { collect(be, c); }
void collect(current: (Expr) `<UnaryExpr ue>`,      Collector c) { collect(ue, c); }
void collect(current: (Expr) `<AtomExpr ae>`,       Collector c) { collect(ae, c); }

void collect(current: (QuantifiedExpr) `<Quantifier _> <ID name> in <ID space> . <Expr body>`, Collector c) {
    c.use(space, {spaceId()});
    c.enterScope(current);
    c.define("<name>", variableId(), current, defType(userType("<space>")));
    collect(body, c);
    c.leaveScope(current);
}

void collect(current: (BinaryExpr) `<AtomExpr left> <BinaryOp _> <AtomExpr right>`, Collector c) {
    collect(left, c);
    collect(right, c);
}

void collect(current: (UnaryExpr) `<UnaryOp _> <AtomExpr ae>`, Collector c) { collect(ae, c); }

void collect(current: (AtomExpr) `<OperatorApp app>`, Collector c) { collect(app, c); }
void collect(current: (AtomExpr) `<ID name>`, Collector c) { c.use(name, {variableId(), operatorId()}); }
void collect(current: (AtomExpr) `( <Expr expr> )`, Collector c) { collect(expr, c); }
void collect(current: (AtomExpr) `∅`, Collector c) { }

void collect(current: (ModuleBodyItem) `<StructDef sd>`, Collector c) { collect(sd, c); }

void collect(current: (StructDef) `defstruct <ID name> : <Type t> <TypedValue* values> end`, Collector c) {
    AType declaredType = toAType(t);
    c.define("<name>", structId(), current, defType(declaredType));
    if (userType(_) := declaredType) {
        c.use(t, {spaceId()});
    }
    collect(values, c);
    if (isPrimitive(declaredType)) {
        for (TypedValue tv <- values) {
            c.require("struct element type matches struct type", tv, [tv], void(Solver s) {
                AType elemType = s.getType(tv);
                if (elemType != declaredType) {
                    s.report(error(tv,
                        "Element type %t does not match the declared struct type %t",
                        [elemType, declaredType]));
                }
            });
        }
    }
}

void collect(current: (TypedValue) `<IntegerLit _> : Integer`, Collector c) { c.fact(current, intType()); }
void collect(current: (TypedValue) `<BooleanLit _> : Boolean`, Collector c) { c.fact(current, boolType()); }
void collect(current: (TypedValue) `<CharLit _> : Char`,       Collector c) { c.fact(current, charType()); }
void collect(current: (TypedValue) `<StringLit _> : String`,   Collector c) { c.fact(current, strType()); }

TModel veriLangTModel(Tree pt) = collectAndSolve(pt);