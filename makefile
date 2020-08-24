.POSIX:
SHELL = /bin/sh
.SUFFIXES: .java .class .g4

DOWNLOAD = curl

LIB = lib

ANTLR_VERSION = 4.8-complete
ANTLR = antlr-$(ANTLR_VERSION).jar
ANTLR_URL = https://www.antlr.org/download/$(ANTLR)

all:

$(LIB)/$(ANTLR):
	if ! test -d "$$(dirname "$@")"; then mkdir "$$(dirname "$@")"; fi
	$(DOWNLOAD) $(DOWNLOADFLAGS) $(ANTLR_URL) > "$@"
