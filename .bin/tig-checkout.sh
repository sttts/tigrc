#!/bin/bash

COMMIT=$(git rev-parse "${1:-HEAD}" 2>/dev/null)

MYTMPDIR=`mktemp -d`
trap "rm -rf $MYTMPDIR" EXIT

git branch --points-at ${COMMIT} 2>/dev/null | grep -v "detached at" | grep -v "*" | gsed -e 's, ,,g;s,^\(\**\)\(.*\),\1git checkout \2\n\1Checkout \2 branch,;s,^\*,git checkout '${COMMIT}' \&\& ,' > "${MYTMPDIR}/refs"
echo -e "git checkout ${COMMIT}\nDetached checkout of ${COMMIT}" >> "${MYTMPDIR}/refs"

if [ -s "${MYTMPDIR}/refs" ]; then
	gxargs -d '\n' dialog --clear --menu foo 0 0 0 2> "${MYTMPDIR}/ref" < "${MYTMPDIR}/refs"
	RC=$?
	clear
	test $RC != 0 && exit $RC
	eval $(cat "${MYTMPDIR}/ref") || (read -n 1 -p "Force [y/n]? " X; test $X = "y" && eval $(cat "${MYTMPDIR}/ref") -f)
fi
