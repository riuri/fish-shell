#!/bin/sh

test_bad() {
	# Two descriptions on the same line
	cat $* | grep -- '--description.*--description'
	cat $* | grep -n -- '--description' | sed 's/^\([0-9]*:\).*--description\(.*\)$/\1\2/' | grep -v '[0-9]*: '
	echo $* | grep ':'
}

pot_output(){
	#grep -n -- '--description' $* | wc -l
	#grep -n -- '--description' $* | sed 's/^\([^:]*\):\([0-9]*\):.*--description ["'"'"']\(.*\)["'"'"']/\1:\2:\3/' | wc -l
	argc=$#
	test $argc -ge 2 && \
	grep -n -- '--description' $* | sed 's/^\([^:]*\):\([0-9]*\):.*--description \(\("\(\([^\"]\|\\.\)*\)"\)\|\('"'\\(\\([^\\']\\|\\(\\\\.\\)\\)*\\)'"'\)\).*$/\
#: \1:\2\
msgid "\5\8"\
msgstr ""\
/' || true
	test $argc = 1 && {
		file_escape="$(echo -n $* | sed 's/[/\\]/\\\0/g')"
		grep -n -- '--description' $* | sed 's/^\([0-9]*\):.*--description \(\("\(\([^\"]\|\\.\)*\)"\)\|\('"'\\(\\([^\\']\\|\\(\\\\.\\)\\)*\\)'"'\)\).*$/\
#: '"$file_escape"':\1\
msgid "\4\7"\
msgstr ""\
/' || true
	}
	test $argc = 0 && \
	grep -n -- '--description' | sed 's/^\([0-9]*\):.*--description \(\("\(\([^\"]\|\\.\)*\)"\)\|\('"'\\(\\([^\\']\\|\\(\\\\.\\)\\)*\\)'"'\)\).*$/\
#: stdin:\1\
msgid "\4\7"\
msgstr ""\
/' || true

}

compatibility() {
	sed 's/.*\(--description.*\)/\1/'
}

transform_dir() {
	cd $1
	mkdir transform original
	for i in *.fish
	do
		compatibility <"$i" >transform/"$i"
		mv "$i" original/
	done
	mv transform/*.fish ./
	cd -
	xgettext -j -k_ -kN_ -k--description -LShell --from-code=UTF-8 $1/*.fish -o messages.pot
	xgettext_status=$?
	cd $1
	rm *.fish
	mv original/*.fish ./
	rmdir transform original
	cd -
	return $xgettext_status
}

#pot_output $*
transform_dir share/completions && transform_dir share/functions
