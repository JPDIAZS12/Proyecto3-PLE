module AST

data AttributeValue
    = attributeValue(str text)
    | emptyAttributeValue();

data Attribute
    = attributeWithValue(str name, AttributeValue attrValue)
    | attributeNoValue(str name);

data Program
    = program(ModuleDef moduleDef);

data ModuleDef
    = moduleDef(str name, list[Import] imports, list[ModuleBodyItem] items);

data Import
    = imp(str name);

data ModuleBodyItem
    = spaceDefItem(SpaceDef spaceDef)
    | operatorDefItem(OperatorDef operatorDef)
    | expressionDefItem(ExpressionDef expressionDef)
    | ruleDefItem(RuleDef ruleDef)
    | variableDefItem(VariableDef variableDef)
    | structDefItem(StructDef structDef);

data SpaceDef
    = spaceDef(str name, SpaceParent parent);

data SpaceParent
    = parent(str name)
    | noParent();

data TypeAtom
    = typeAtom(Type typeVal);

data TypeSig
    = typeSig(TypeAtom first, list[TypeSigTail] rest);

data TypeSigTail
    = typeSigTail(TypeAtom atom);

data OperatorDef
    = operatorDef(str name, TypeSig typeSig, list[Attribute] attributes);

data VariableDef
    = variableDef(list[VarBinding] bindings);

data VarBinding
    = varBinding(str name, Type typeName);

data Term
    = termId(str name)
    | termEmpty();

data OperatorApp
    = operatorApp(str name, list[Term] terms);

data RuleDef
    = ruleDef(OperatorApp left, OperatorApp right);

data Quantifier
    = forall()
    | exists()
    | defer();

data BinaryOp
    = add() | sub() | mul() | div() | pow() | modulo()
    | lt() | gt() | leq() | geq() | neq() | eq()
    | impl() | equiv() | andOp() | orOp() | inOp() | arrowOp();

data UnaryOp
    = minus()
    | neg();

data AtomExpr
    = operatorAtom(OperatorApp operatorApp)
    | idExpr(str name)
    | parenExpr(Expr expr)
    | emptyExpr();

data BinaryExpr
    = binaryExpr(AtomExpr left, BinaryOp op, AtomExpr right);

data UnaryExpr
    = unaryExpr(UnaryOp op, AtomExpr expr);

data QuantifiedExpr
    = quantifiedExpr(Quantifier quantifier, str variable, str spaceName, Expr expr);

data Expr
    = quantifiedExprNode(QuantifiedExpr quantifiedExpr)
    | binaryExprNode(BinaryExpr binaryExpr)
    | unaryExprNode(UnaryExpr unaryExpr)
    | atomExprNode(AtomExpr atomExpr);

data ExpressionDef
    = expressionDef(Expr expr, list[Attribute] attributes);

// ─── Punto 4: Tipos y estructuras de datos ─────────────────────────────────

data Type
    = intType()
    | boolType()
    | charType()
    | strType()
    | userType(str name);

data TypedValue
    = intVal(str val)
    | boolVal(str val)
    | charVal(str val)
    | strVal(str val);

data StructDef
    = structDef(str name, Type structType, list[TypedValue] values);
