#!/bin/sh

echo ">>> Cloning docs repo"
rm -rf ~/tmp/docs && git clone git@github.com:vtex/docs.git ~/tmp/docs
echo ">>> Cleaning"
rm -rf ~/tmp/docs/pt-br/vtex.js/lib && mkdir ~/tmp/docs/pt-br/vtex.js/lib
echo ">>> Generating docs"
gulp doc
echo ">>> Copying"
cp -r doc/* ~/tmp/docs/pt-br/vtex.js/lib/
echo ">>> Pushing"
(cd ~/tmp/docs && git add . -A && git commit -m "Atualiza documentação do vtex.js" && git push)
echo ">>> Done!"
