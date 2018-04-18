#!/bin/bash
BRANCH=$(git branch | grep \* | sed 's/* //g')
rm -f hostdir/binpkgs/$BRANCH/$1*
rm -f hostdir/binpkgs/$BRANCH/lib$1*
xbps-rindex --clean hostdir/binpkgs/$BRANCH
./xbps-src -j $(nproc) pkg $1
