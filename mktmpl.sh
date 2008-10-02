#!/bin/sh
#
#-
# Copyright (c) 2008 Juan Romero Pardines.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#-
#
# Shell script to automate the creation of new templates for pkgfs.
# Only writes basic stuff into the template, if you need advanced stuff
# you'll have to do that manually.
#
# At least it will fetch the distfile and compute the checksum, plus
# other stuff for free... so it's not that bad, heh.
#
# Supports GNU configure, configure and perl module templates for now.
#
: ${ftp_cmd:=/usr/bin/ftp -a}
: ${awk_cmd:=/usr/bin/awk}
: ${cksum_cmd:=/usr/bin/cksum -a rmd160}
: ${sed_cmd:=/usr/bin/sed}
: ${db_cmd:=/usr/bin/db -q}
: ${config_file:=/usr/local/etc/pkgfs.conf}
: ${chmod_cmd:=/bin/chmod}

required_deps=

write_new_template()
{
	local tmpldir="$PKGFS_DISTRIBUTIONDIR/templates"
	local depsdir="$PKGFS_DISTRIBUTIONDIR/dependencies"
	local distdir="$PKGFS_SRCDISTDIR"
	local checksum=
	local dfile=
	local tmplname=

	[ ! -d $distdir -o ! -d $tmpldir -o ! -d $depsdir ] && exit 1

	save_pwd=$(pwd -P 2>/dev/null)
	echo "=> Fetching distfile from $url"
	cd $distdir && $ftp_cmd $url
	[ "$?" -ne 0 ] && echo "Error fetching file, aborting." && exit 1

	dfile=$(basename $url)
	checksum=$($cksum_cmd $dfile|$awk_cmd '{print $4}')
	[ -z "$checksum" ] && echo "Checksum empty, aborting." && exit 1

	cd $save_pwd

	pkg="$pkgname-$version"
	pkg_sufx=${dfile##$pkg}

	if [ "$build_style" = "g" ]; then
		build_style=gnu_configure
	elif [ "$build_style" = "p" ]; then
		build_style=perl_module
		tmplname="perl-"
	else
		build_style=configure
	fi

	if [ -f "$tmpldir/$pkg.tmpl" ]; then
		echo "There's an existing template with the same name, do you"
		echo -n "want to overwrite it? (y)es or (n)o: "
		read overwrite
		if [ "$overwrite" = "n" ]; then
			echo "not overwriting... bye."
			exit 1
		elif [ -z "$overwrite" ]; then
			echo "no answer?... will overwrite"
		fi
	fi

	(								\
		echo "# Template build file for '$tmplname$pkg'.";	\
		echo "pkgname=$tmplname$pkg";				\
		if [ -n "$perl_module" ]; then				\
			echo "distfiles=\"$pkg\"";			\
		fi;							\
		echo "extract_sufx=\"$pkg_sufx\"";			\
		echo "url=${url%%/$dfile}";				\
		echo "build_style=$build_style";			\
		if [ -n "$dep_gmake" ]; then				\
			echo "make_cmd=\"\$PKGFS_MASTERDIR/bin/gmake\"";	\
		fi;							\
		if [ -n "$pcfiles" ]; then				\
			echo "pkgconfig_override=\"$pcfiles\"";		\
		fi;							\
		echo "short_desc=\"$short_desc\"";			\
		echo "maintainer=\"$maintainer\"";			\
		echo "checksum=$checksum";				\
		echo "long_desc=\"...\"";				\
	) > $tmpldir/$tmplname$pkg.tmpl

	if [ ! -r "$tmpldir/$tmplname$pkg.tmpl" ]; then
		echo "Couldn't write template, aborting."
		exit 1
	fi

	$chmod_cmd 755 $tmpldir/$tmplname$pkg.tmpl

	if [ -n "$deps" ]; then
		for i in $required_deps; do
			deps="$i $deps"
		done
		[ -n "$pcfiles" ] && deps="pkg-config-0.23 $deps"
		[ -n "$perl_module" ] && deps="perl-5.10.0 $deps"

		$db_cmd -C -P 512 -w btree $depsdir/$tmplname$pkg-deps.db deps \
			"$deps" 2>&1 >/dev/null
		[ "$?" -ne 0 ] && \
			echo "Errong writing dependencies db file." && exit 1
	fi

	echo
	echo "=> Template created at: $tmpldir/$tmplname$pkg.tmpl"
	echo
	echo "If you need more changes, do them manually. You can also look"
	echo "at $tmpldir/example.tmpl to know what variables can be used and"
	echo "to learn about their meanings. Don't forget to set \$long_desc!"
	echo
	echo "Happy hacking!"
}

read_parameters()
{
	if [ ! -f "$config_file" ]; then
		echo "-- Configuration file cannot be read --"
		exit 1
	fi

	. $config_file

	echo -n "Enter name of this package: "
	read pkgname

	[ -z "$pkgname" ] && echo "-- Empty value --" && exit 1

	echo -n "Enter version number of this package: "
	read version

	[ -z "$version" ] && echo "-- Empty value --" && exit 1

	echo "What's the build style for this template?"
	echo -n "(g)nu_configure, (c)onfigure, (p)erl_module: "
	read build_style
	echo

	if [ -z "$build_style" ]; then
		echo " -- Empty value --"
		exit 1
	elif [ "$build_style" = "g" ]; then
		gnu_configure=yes
	elif [ "$build_style" = "c" ]; then
		configure=yes
	elif [ "$build_style" = "p" ]; then
		perl_module=yes
	else
		echo " -- Invalid answer --"
		exit 1
	fi

	echo -n "Requires GNU libtool this package? (y) or (n): "
	read dep_libtool
	[ "$dep_libtool" = "y" ] && \
		required_deps="libtool-2.2.6a $required_deps"

	echo -n "Requires GNU make this package? (y) or (n): "
	read dep_gmake
	echo
	[ "$dep_gmake" = "y" ] && \
		required_deps="gmake-3.81 $required_deps"
	[ "$dep_gmake" = "n" ] && dep_gmake=

	echo "Please enter exact dependencies required for this template."
	echo "They must be separated by whitespaces, e.g: foo-1.0 blah-2.0."
	echo
	echo "If it's a perl module or uses libtool/gmake, the dependency"
	echo "will be added automatically so don't add them here again!"
	echo -n "> "
	read deps
	echo
	[ -z "$deps" ] && echo "No dependencies, continuing..."

	echo "Will this package install pkg-config files?"
	echo "If true, enter the names of the files with the .pc extension"
	echo "and separated with whitespaces between them, e.g: foo.pc blah.pc."
	echo
	echo "Alternatively press the enter key to ignore this question."
	echo -n "> "
	read pcfiles
	echo

	echo "Enter full URL to download the distfile: "
	echo -n "> "
	read url
	echo
	[ -z "$url" ] && echo " -- Empty value --" && exit 1

	echo "Enter short description (max 72 characters):"
	echo -n "> "
	read short_desc
	echo

	echo "Enter maintainer for this package, e.g: Anon <ymous.org>:"
	echo "Alternatively press enter to ignore this question."
	echo -n "> "
	read maintainer
	echo

	write_new_template
}

#
# If user specified a full path to pkgfs.conf, use it. Otherwise look
# at default location, and as last resort current dir.
#
if [ -n "$1" ]; then
	config_file="$1"
fi

if [ ! -f "$config_file" ]; then
	config_file="$(pwd -P 2>/dev/null)/pkgfs.conf"
	if [ -f "$config_file" ]; then
		echo "$(basename $0): cannot find configuration file"
		echo "Please speficify it, e.g: $(basename $0) /path/to/pkgfs.conf"
		exit 1
	fi
fi

read_parameters
exit $?
