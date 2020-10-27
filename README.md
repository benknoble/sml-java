# SML-Java

Deprecated in favor of using SML-NJ's parser and interfacing with java in some
other way

[![This project is considered experimental](https://img.shields.io/badge/status-experimental-critical.svg)](https://benknoble.github.io/status/experimental/)

An SML parser built in java using ANTLR 4.

An [SML Grammar](https://people.mpi-sws.org/~rossberg/sml.html) is reproduced in
[doc/smlgrammar.html](doc/smlgrammar.html) (with a minor correction: type
variables cannot be empty).

Limitations
- patterns and infix-operator definitions cannot contain `=`
- some declarations and functions are parsed incorrectly due to a lack of type
  and precedence information
  - they "parse," but the tree is wrong and needs to be corrected. Often the
    issue is that `:` or other identifiers, which are intended to separate some
    semantic pieces, are pulled in as parts of the pattern, which is wrong
- strings don't yet parse correctly
