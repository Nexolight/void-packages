#!/bin/bash
BRANCH=$(git branch | grep \* | sed 's/* //g')
rm -rf hostdir/binpkgs/$BRANCH/$1*
xbps-rindex --clean hostdir/binpkgs/$BRANCH
./xbps-src -j $(nproc) pkg $1
