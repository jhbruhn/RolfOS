#!/bin/sh

cd doc
files=`find ../source/features/ -name '*.asm' | tr -s '\\n'`

tools/asm4doxy.pl -ud $files

doxygen Doxyfile

rm *.c

git checkout gh-pages
cp -R doc/html/* ./
git add . -A
git commit -m "changes to docs"
git push origin gh-pages
git checkout master