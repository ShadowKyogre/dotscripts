#!/bin/sh

TIME1=$(date "+%Y-%m-%d %H:%M:%S")

"${EDITOR:-vim}" "$@"
EXIT_CODE="$?"
TIME2=$(date "+%Y-%m-%d %H:%M:%S")

if [[ "${EXIT_CODE}" == 0 ]]; then
	printf "${TIME1}\t${TIME2}\n" 1>&2
	if git rev-parse --git-dir > /dev/null 2>&1; then
		printf "Saving write burst to git repo\n" 1>&2
		git-timelog.sh "${TIME1}" "${TIME2}"
	fi
fi
