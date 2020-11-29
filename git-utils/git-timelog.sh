#!/bin/sh

if [[ -z "${1}" ]];then
	echo "Need a start date!"
	exit 1
fi

if [[ -z "${2}" ]];then
	echo "Need an end date!"
	exit 1
fi

message="$(printf "short: summary\n\nYour remarks for later here.\n")"

# Make sure you configure git properly!
# https://stackoverflow.com/questions/2683248/can-i-add-metadata-to-git-commits-or-can-i-hide-some-tags-in-gitk
# This setup assumes that you're namespacing your notes right in git!

git add .
git commit -m "${message}"
git notes --ref=timelog add -m "Write Burst Start: ${1}" -m "Write Burst End: ${2}"
