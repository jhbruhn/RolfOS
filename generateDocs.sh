#!/bin/sh

cd doc
files=`find ../source/features/ -name '*.asm' | tr -s '\\n'`

tools/asm4doxy.pl -ud $files

doxygen Doxyfile

rm *.c

