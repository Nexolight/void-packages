#!/bin/bash
BRANCH=$(git branch | grep \* | sed 's/* //g')
rm -f hostdir/binpkgs/$BRANCH/$1*
rm -f hostdir/binpkgs/$BRANCH/lib$1*
xbps-rindex --clean hostdir/binpkgs/$BRANCH
#./xbps-src -m masterdir-i686 binary-bootstrap i686
./xbps-src -j $(nproc) -m masterdir-i686 pkg $1
