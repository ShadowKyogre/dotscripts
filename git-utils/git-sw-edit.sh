#!/bin/sh

TIME1=$(date "+%Y-%m-%d %H:%M:%S")

"${EDITOR:-vim}" "$@"
EXIT_CODE="$?"
TIME2=$(date "+%Y-%m-%d %H:%M:%S")

if [[ "${EXIT_CODE}" == 0 ]]; then
	git-timelog.sh "${TIME1}" "${TIME2}"
fi
