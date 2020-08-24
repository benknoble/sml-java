grammar SML;

Whitespace : [ \t\r\n]+ -> skip ;
Comment : '(*' .*? '*)' -> skip ;

// Module language {{{
// programs {{{
program
    : (declaration
      | 'functor' functorbinding
      | 'signature' signaturebinding
      | ';'
      )*
    EOF
    ;

functorbinding
    : ( ID '(' ID ':' signature ')' (':' '>'? signature)? '=' struct
      | ID '(' spec?            ')' (':' '>'? signature)? '=' struct
      )
    ('and' functorbinding)*
    ;

signaturebinding : ID '=' signature ('and' signaturebinding)* ;
// }}}

// signatures {{{
signature
    : ID
    | 'sig' spec? 'end'
    | signature 'where type' typerefinement
    ;

typerefinement : VARS? LONGID '=' type ('and type' typerefinement)* ;

spec
    : 'val' valspec
    | 'type' typespec
    | 'eqtype' typespec
    | 'type' typebinding
    | 'datatype' dataspec
    | 'datatype' ID '= datatype' LONGID
    | 'exception' exceptionspec
    | 'structure' structspec
    | 'include' signature
    | 'include' ID+
    | spec 'sharing type' LONGID ('=' LONGID)+
    | spec 'sharing' LONGID ('=' LONGID)+
    | spec ';'? spec
    ;

valspec : ID ':' type ('and' valspec)* ;
typespec : VARS? ID ('and' typespec)* ;
dataspec : VARS? ID '=' constructorspec ('and' dataspec)* ;
constructorspec : ID ('of' type)? ('|' constructorspec)* ;
exceptionspec : ID ('of' type)? ('and' exceptionspec)* ;
structspec : ID ':' signature ('and' structspec)* ;
// }}}

// structures {{{
struct
    : LONGID
    | 'struct' declaration? 'end'
    | struct ':' '>'? signature
    | ID '(' struct ')'
    | ID '(' declaration? ')'
    | 'let' declaration? 'in' struct 'end'
    ;
structbinding : ID (':' '>'? signature)? '=' struct ('and' structbinding)* ;
// }}}
// }}}

// Core language {{{
// declarations {{{
declaration
    : ( 'structure' structbinding
      | 'val' VARS? valbinding
      | 'fun' VARS? funbinding
      | 'type' typebinding
      | 'datatype' databinding ('withtype' typebinding)?
      | 'datatype' ID '= datatype' LONGID
      | 'abstype' ID '=' ('withtype' typebinding)? 'with' declaration? 'end'
      | 'exception' exceptionbinding
      | 'local' declaration? 'in' declaration? 'end'
      | 'open' LONGID+
      | 'nonfix' LONGID+
      | 'infix' DIGIT ID+
      | 'infixr' DIGIT ID+
      | ';'
      )+
    ;

valbinding
    : pattern '=' expression ('and' valbinding)*
    | 'rec' valbinding
    ;

funbinding : funmatch ('and' funbinding) ;
funmatch
    : ( 'op'? ID pattern+
      | pattern ID pattern
      | '(' pattern ID pattern ')' pattern*
      )
    (':' type)? '=' expression
    ('|' funmatch)*
    ;

typebinding : VARS? ID '=' type ('and' typebinding)* ;
databinding : VARS? ID '=' constructorbinding ('and' databinding)* ;
constructorbinding : ID ('of' type)? ('|' constructorbinding)* ;
exceptionbinding
    : ( ID ('of' type)?
      | ID '=' LONGID
      )
    ('and' exceptionbinding)*
    ;
// }}}

// types {{{
type
    : VAR
    | '(' type ')'
    | LONGID
    | type LONGID
    | ('(' type (',' type)* ')')? LONGID
    | type '->' type
    | type ('*' type)+
    | '{' typerow '}'
    ;
typerow : LABEL ':' type (',' typerow)* ;
// }}}

// patterns {{{
pattern
    : CONSTANT
    | '_'
    | 'op'? ID
    | 'op'? LONGID pattern?
    | pattern ID pattern
    | '()'
    | '(' pattern ')'
    | '(' pattern (',' pattern)+ ')'
    | '{' patternrow '}'
    | '[' (pattern (',' pattern)*)? ']'
    | pattern ':' type
    | 'op' ID (':' type)? 'as' pattern
    ;
patternrow
    : ( '...'
      | LABEL '=' pattern
      | ID (':' type)? ('as' pattern)?
      )
    (',' patternrow)*
    ;
// }}}

// expressions {{{
expression
    : CONSTANT
    | 'op'? LONGID
    | expression expression
    | expression ID expression
    | '()'
    | '(' expression ')'
    | '(' expression (',' expression)+ ')'
    | '{' expressionrow '}'
    | '#' LABEL
    | '[' (expression (',' expression)*)? ']'
    | '(' expression (';' expression)+ ')'
    | 'let' declaration? 'in' expression 'end'
    | expression ':' type
    | 'raise' expression
    | expression 'handle' match
    | expression 'andalso' expression
    | expression 'orelse' expression
    | 'if' expression 'then' expression 'else' expression
    | 'while' expression 'do' expression
    | 'case' expression 'of' match
    | 'fn' match
    ;
expressionrow : LABEL '=' expression (',' expressionrow)* ;
match : pattern '=>' expression ('|' match)* ;
// expressions }}}

// identifiers {{{
/* the symbolic half is disallowed in certain contexts, but since we're only
 * interested in style checks we'll ignore it. A proper compiler would either
 * separater this appropriate or catch identifier errors during one of the
 * context-sensitive passes
 */
ID
    : LETTER (LETTER | DIGIT | ['_])*
    | [!%&$#+-/:<=>?@\\~`^|*]+ ;
VAR
    : ['](LETTER | DIGIT | ['_])+
    | [']['](LETTER | DIGIT | ['_])+
    ;
VARS
    : VAR
    | '(' VAR (',' VAR)* ')'
    ;
LONGID : ID ('.' ID)* ;
/* the latter half (digits) is really for tuple accesses, so appears nonsensical
 * in
 *      val {1=x, 2=y} = (5,6)
 * but the genius of SML is that this actually binds x to 5 and y to 6! Tuples
 * are akin to records with numeric labels (starting from 1), and SML defaults
 * to allowing you to treat them as such.
 */
LABEL
    : ID
    | [1-9] NUM*
    ;
// identifiers }}}

// constants {{{
CONSTANT
    : INT
    | WORD
    | FLOAT
    | CHAR
    | STRING
    ;
INT
    : '~'? NUM
    | '~'? '0x' HEX
    ;
WORD
    : '0w' NUM
    | '0wx' HEX
    ;
FLOAT
    : '~'? NUM '.' NUM
    | '~'? NUM ('.' NUM)? 'e' '~'? NUM
    ;
CHAR : '#"' ASCII '"' ;
STRING : '"' ASCII* '"' ;
NUM : DIGIT+ ;
HEX : (DIGIT | [ABCDEF])+ ;

DIGIT : [0-9] ;
fragment ASCII
    : '\\"'
    | [a-zA-Z`~!@#$%^&*()_+={}\\|;:',.<>/?]
    | '[' | ']' | '-'
    ;
fragment LETTER : [a-zA-Z] ;
// constants }}}
// }}}
