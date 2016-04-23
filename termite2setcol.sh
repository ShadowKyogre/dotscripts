#!/bin/bash

# http://web.archive.org/web/20150225020624/http://phraktured.net/linux-console-colors.html

for num in {0..15};do
	color="$(grep "^color${num}\s\+" "${1:-${HOME}/.config/termite/config}"|grep -o "[0-9a-f]\{3,6\}$")"
	echo "${num}#${color}"
done
