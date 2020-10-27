.POSIX:
SHELL = /bin/sh
.SUFFIXES: .java .class .g4

DOWNLOAD = curl

LIB = lib

ANTLR_VERSION = 4.5.1-complete
ANTLR = antlr-$(ANTLR_VERSION).jar
ANTLR_URL = https://www.antlr.org/download/$(ANTLR)

BUILD = build
BIN = bin

all: $(BIN)/SMLParser.class

$(LIB)/$(ANTLR):
	if ! test -d "$$(dirname '$@')"; then mkdir "$$(dirname '$@')"; fi
	$(DOWNLOAD) $(DOWNLOADFLAGS) '$(ANTLR_URL)' > '$@'

$(BUILD)/SMLParser.java: SMLParser.g4 SMLLexer.g4
	scripts/antlr4 -o '$(BUILD)' SMLLexer.g4 SMLParser.g4

$(BIN)/SMLParser.class: $(BUILD)/SMLParser.java
	javac -d bin -classpath '$(LIB)/*:$(BUILD):$(CLASSPATH)' '$(BUILD)'/*.java

clean:
	-$(RM) -r '$(BUILD)' '$(BIN)'

distclean: clean
	-git clean -fxd
