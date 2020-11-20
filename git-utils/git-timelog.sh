#!/bin/sh

if [[ -z "${1}" ]];then
	echo "Need a start date!"
	exit 1
fi

if [[ -z "${2}" ]];then
	echo "Need an end date!"
	exit 1
fi

message="$(printf "short: summary\n\n${1}\t${2}\n\nYour remarks for later here.\n")"

git add .
git commit -m "${message}"
