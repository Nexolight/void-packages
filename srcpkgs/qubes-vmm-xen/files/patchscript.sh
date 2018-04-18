#!/bin/bash
SFILE=$(readlink -f "$0")
SDIR=$(dirname "$SFILE")

SERIES="$1"
PATCHDIR="$2"

grep -Ev "^\s*#|^\s*$" "$SERIES" | \
xargs -i bash -c "echo n | patch -s -F0 -E -p1 --no-backup-if-mismatch -i $PATCHDIR/{}"
