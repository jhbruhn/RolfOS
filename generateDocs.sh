#!/bin/sh

cd doc
files=`find ../source/features/ -name '*.asm' | tr -s '\\n'`

tools/asm4doxy.pl -ud $files

doxygen Doxyfile

rm *.c

git add ./ -A
git commit -m "changes to docs"

git checkout gh-pages
git merge master --strategy=ours --no-commit
cp -R html/* ./
git push origin gh-pages
git checkout master