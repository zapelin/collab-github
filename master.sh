#!/bin/bash

git checkout master
git pull
echo a > $1
echo b >> $1
git add $1
git commit -m m
git push
git checkout -
git merge master --no-ff
git push