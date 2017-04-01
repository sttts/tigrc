#!/bin/bash

COMMIT=$(git rev-parse "${1:-HEAD}" 2>/dev/null)

MYTMPDIR=`mktemp -d`
trap "rm -rf $MYTMPDIR" EXIT

git branch --points-at ${COMMIT} 2>/dev/null | grep -v "detached at" | gsed -e 's, ,,g;s,^\(\**\)\(.*\),\1git branch -D \2\n\1Delete \2 branch,;s,^*,git checkout '${COMMIT}' \&\& ,' > "${MYTMPDIR}/refs"
git describe --tags --exact-match ${COMMIT} 2>/dev/null | gsed -e 's,^.*,git tag -d \0\nDelete tag \0,' >> "${MYTMPDIR}/refs"

if [ -s "${MYTMPDIR}/refs" ]; then
	gxargs -d '\n' dialog --clear --menu foo 0 0 0 2> "${MYTMPDIR}/ref" < "${MYTMPDIR}/refs"
	RC=$?
	clear
	test $RC != 0 && exit $RC
	eval $(cat "${MYTMPDIR}/ref")
fi
