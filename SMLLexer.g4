lexer grammar SMLLexer;

// common pieces {{{
DIGIT: [0-9];
fragment LETTER: [a-zA-Z];
// common fragments }}}

// whitespace {{{
Whitespace: [ \t\r\n]+ -> skip;
Comment: '(*' .*? '*)' -> skip;
// whitespace }}}

VAR
    : TICK (LETTER | DIGIT | UNDERSCORE | TICK)+
    | TICK TICK (LETTER | DIGIT | UNDERSCORE | TICK)+
    ;

// keywords & punctuation {{{
FUNCTOR: 'functor';
SIGNATURE: 'signature';
ANDALSO: 'andalso';
AND: 'and';
SIG: 'sig';
END: 'end';
WHERE: 'where';
TYPE: 'type';
VAL: 'val';
EQTYPE: 'eqtype';
DATATYPE: 'datatype';
EXCEPTION: 'exception';
STRUCTURE: 'structure';
INCLUDE: 'include';
SHARING: 'sharing';
OF: 'of';
STRUCT: 'struct';
LET: 'let';
IN: 'in';
FUN: 'fun';
WITHTYPE: 'withtype';
ABSTYPE: 'abstype';
WITH: 'with';
LOCAL: 'local';
OPEN: 'open';
NONFIX: 'nonfix';
INFIXR: 'infixr';
INFIX: 'infix';
REC: 'rec';
OP: 'op';
AS: 'as';
RAISE: 'raise';
HANDLE: 'handle';
ORELSE: 'orelse';
IF: 'if';
THEN: 'then';
ELSE: 'else';
WHILE: 'while';
DO: 'do';
CASE: 'case';
FN: 'fn';

SEMI: ';';
LPAREN: '(';
RPAREN: ')';
COLON: ':';
RANGLE: '>';
LANGLE: '<';
EQ: '=';
BAR: '|';
COMMA: ',';
TY_ARROW: '->';
STAR: '*';
LCURLY: '{';
RCURLY: '}';
UNDERSCORE: '_';
LSQUARE: '[';
RSQUARE: ']';
ELLIPSIS: '...';
HASH: '#';
FN_ARROW: '=>';
DOT: '.';
fragment TICK: '\'';
BANG: '!';
PERCENT: '%';
AMPERSAND: '&';
DOLLAR: '$';
PLUS: '+';
MINUS: '-';
SLASH: '/';
QUESTION: '?';
AT: '@';
BACKSLASH: '\\';
TILDE: '~';
BACKTICK: '`';
CARET: '^';
// keywords & punctuation }}}

IDENTIFIER: LETTER (LETTER | DIGIT | UNDERSCORE | TICK)*;

// literals {{{
WORD_PREFIX: '0w';

INT_HEX_LITERAL: '0x' -> more, mode(HEX);
WORD_HEX_LITERAL: 'x' -> more, mode(HEX);

FLOAT_SEP: 'e';

CHAR_START: '#"' -> mode(CHAR);
STRING: '"' -> more, mode(STR);

mode HEX; // avoid overlap with LETTER, ID, etc.
fragment HEX_DIGIT: [0-9a-fA-F];
HEX_LITERAL: HEX_DIGIT+ -> mode(DEFAULT_MODE);

mode CHAR;
CHAR_REST: (DIGIT | LETTER | OTHER_ASCII) '"' -> mode(DEFAULT_MODE);

mode STR;
fragment OTHER_ASCII
    : '\\"'
    | [`~!@#$%^&*()_+={}\\|;:',.<>/?]
    | '[' | ']' | '-'
    ;
STRING_REST: (DIGIT | LETTER | OTHER_ASCII)* '"' -> mode(DEFAULT_MODE);
// literals }}}
