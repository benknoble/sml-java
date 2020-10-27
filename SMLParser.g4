parser grammar SMLParser;

options {
    tokenVocab = SMLLexer;
}

// Module language {{{
// programs {{{
program
    : (declaration
      | FUNCTOR functorbinding
      | SIGNATURE signaturebinding
      | SEMI
      )*
    EOF
    ;

functorbinding
    : ( id LPAREN id COLON signature RPAREN (COLON RANGLE? signature)? EQ struct
      | id LPAREN spec?              RPAREN (COLON RANGLE? signature)? EQ struct
      )
    (AND functorbinding)*
    ;

signaturebinding : id EQ signature (AND signaturebinding)* ;
// }}}

// signatures {{{
signature
    : id
    | SIG spec? END
    | signature WHERE TYPE typerefinement
    ;

typerefinement : vars? longid EQ type (AND TYPE typerefinement)* ;

spec
    : (
        // base spec
        ( VAL valspec
        | TYPE typespec
        | EQTYPE typespec
        | TYPE typebinding
        | DATATYPE dataspec
        | DATATYPE id EQ DATATYPE longid
        | EXCEPTION exceptionspec
        | STRUCTURE structspec
        | INCLUDE signature
        | INCLUDE id+
        | SEMI
        )
        // sharing constraint
        ( SHARING TYPE longid (EQ longid)+
        | SHARING longid (EQ longid)+
        )?
      )+
    ;

valspec : id COLON type (AND valspec)* ;
typespec : vars? id (AND typespec)* ;
dataspec : vars? id EQ constructorspec (AND dataspec)* ;
constructorspec : id (OF type)? (BAR constructorspec)* ;
exceptionspec : id (OF type)? (AND exceptionspec)* ;
structspec : id COLON signature (AND structspec)* ;
// }}}

// structures {{{
struct
    : longid
    | STRUCT declaration? END
    | struct COLON RANGLE? signature
    | id LPAREN struct RPAREN
    | id LPAREN declaration? RPAREN
    | LET declaration? IN struct END
    ;
structbinding : id (COLON RANGLE? signature)? EQ struct (AND structbinding)* ;
// }}}
// }}}

// Core language {{{
// declarations {{{
declaration
    : ( STRUCTURE structbinding
      | VAL vars? valbinding
      | FUN vars? funbinding
      | TYPE typebinding
      | DATATYPE databinding (WITHTYPE typebinding)?
      | DATATYPE id EQ DATATYPE longid
      | ABSTYPE databinding (WITHTYPE typebinding)? WITH declaration? END
      | EXCEPTION exceptionbinding
      | LOCAL declaration? IN declaration? END
      | OPEN longid+
      | NONFIX longid+
      | INFIX DIGIT? id+ // must be 0-9; not enforced
      | INFIXR DIGIT? id+ // must be 0-9; not enforced
      | SEMI
      )+
    ;

valbinding
    : pattern EQ expression (AND valbinding)*
    | REC valbinding
    ;

funbinding : funmatch (AND funbinding)* ;
funmatch
    : ( OP? id pattern+?
      | pattern id_noeq pattern
      | LPAREN pattern id pattern RPAREN pattern*?
      )
    (COLON type)? EQ expression
    (BAR funmatch)*
    ;

typebinding : vars? id EQ type (AND typebinding)* ;
databinding : vars? id EQ constructorbinding (AND databinding)* ;
constructorbinding : id (OF type)? (BAR constructorbinding)* ;
exceptionbinding
    : ( id (OF type)?
      | id EQ longid
      )
    (AND exceptionbinding)*
    ;
// }}}

// types {{{
type
    : VAR
    | LPAREN type RPAREN
    | longid
    | type longid
    | (LPAREN type (COMMA type)* RPAREN)? longid
    | type TY_ARROW type
    | type (STAR type)+
    | LCURLY typerow RCURLY
    ;
typerow : label COLON type (COMMA typerow)* ;
// }}}

// patterns {{{
pattern
    : literal
    | UNDERSCORE
    | OP? longid pattern?
    | pattern id_noeq pattern
    | LPAREN RPAREN
    | LPAREN pattern RPAREN
    | LPAREN pattern (COMMA pattern)+ RPAREN
    | LCURLY patternrow RCURLY
    | LSQUARE (pattern (COMMA pattern)*)? RSQUARE
    | pattern COLON type
    | OP? id (COLON type)? AS pattern
    ;
patternrow
    : ( ELLIPSIS
      | label EQ pattern
      | id (COLON type)? (AS pattern)?
      )
    (COMMA patternrow)*
    ;
// }}}

// expressions {{{
expression
    : literal
    | expression expression
    | expression id expression
    | OP? longid
    | LPAREN RPAREN
    | LPAREN expression RPAREN
    | LPAREN expression (COMMA expression)+ RPAREN
    | LCURLY expressionrow RCURLY
    | HASH label
    | LSQUARE (expression (COMMA expression)*)? RSQUARE
    | LPAREN expression (SEMI expression)+ RPAREN
    | LET declaration? IN expression END
    | expression COLON type
    | RAISE expression
    | expression HANDLE match
    | expression ANDALSO expression
    | expression ORELSE expression
    | IF expression THEN expression ELSE expression
    | WHILE expression DO expression
    | CASE expression OF match
    | FN match
    ;
expressionrow : label EQ expression (COMMA expressionrow)* ;
match : pattern FN_ARROW expression (BAR match)* ;
// expressions }}}
// }}}

// common pieces {{{
// identifiers {{{
/* the symbolic half is disallowed in certain contexts, but since we're only
 * interested in style checks we'll ignore it. A proper compiler would either
 * separater this appropriate or catch identifier errors during one of the
 * context-sensitive passes
 */
id
    : IDENTIFIER
    | ( BANG | PERCENT | AMPERSAND | DOLLAR | HASH | PLUS | MINUS | SLASH
      | COLON | LANGLE | EQ | RANGLE | QUESTION | AT | BACKSLASH | TILDE
      | BACKTICK | TILDE | STAR
      )+
    ;

longid : id (DOT id)* ;

id_noeq
    : IDENTIFIER
    | ( BANG | PERCENT | AMPERSAND | DOLLAR | HASH | PLUS | MINUS | SLASH
      | COLON | LANGLE | RANGLE | QUESTION | AT | BACKSLASH | TILDE
      | BACKTICK | TILDE | BAR | STAR
      )+
    ;
// identifiers }}}

vars
    : VAR
    | LPAREN VAR (COMMA VAR)* RPAREN
    ;

/* the latter half (digits) is really for tuple accesses, so appears nonsensical
 * in
 *      val {1=x, 2=y} = (5,6)
 * but the genius of SML is that this actually binds x to 5 and y to 6! Tuples
 * are akin to records with numeric labels (starting from 1), and SML defaults
 * to allowing you to treat them as such.
 */
label
    : id
    | DIGIT+ // must not start with 0; not enforced
    ;

literal
    : intliteral
    | wordliteral
    | floatliteral
    | charliteral
    | stringliteral
    ;

intliteral
    : TILDE? DIGIT+
    | TILDE? INT_HEX_LITERAL
    ;

wordliteral
    : WORD_PREFIX DIGIT+
    | WORD_PREFIX WORD_HEX_LITERAL
    ;

floatliteral
    : TILDE? DIGIT+ DOT DIGIT+
    | TILDE? DIGIT+ (DOT DIGIT+)? FLOAT_SEP TILDE? DIGIT+
    ;

charliteral: CHAR_START CHAR_REST;
stringliteral: STRING;
// common pieces }}}
