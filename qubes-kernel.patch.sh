#!/bin/bash
KERNEL=$1
if [ -z "$KERNEL" ]; then
	echo "Pass the version as argument. Like: linux4.15"
	exit
fi

sed 's|# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set|CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y|g' -i srcpkgs/$KERNEL/files/i386-dotconfig
sed 's|# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set|CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y|g' -i srcpkgs/$KERNEL/files/x86_64-dotconfig
