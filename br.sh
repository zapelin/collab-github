#!/bin/bash

git checkout master
git pull
git checkout -b $1
echo a > $1
git add $1
git commit -m 1
echo b >> $1
git add $1
git commit -m 2
git push --set-upstream origin $1