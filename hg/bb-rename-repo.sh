#!/bin/sh

if [ ! -e "$HOME/.config/.bb_auth" ];then
	2>&1 echo "Can't find bitbucket auth file"
	exit 1
fi

BB_LOGIN="$(sed -n 1p "$HOME/.config/.bb_auth")"
BB_PW="$(sed -n 2p "$HOME/.config/.bb_auth")"
BB_USER="$(sed -n 3p "$HOME/.config/.bb_auth")"

if [ "$#" -lt 2 ];then
	exit 1
fi

curl --user "${BB_LOGIN}:${BB_PW}" \
	-X PUT \
	"https://api.bitbucket.org/1.0/repositories/${BB_USER}/$1" \
	--data name="$2" \
	--data is_private='true'|jq '.slug, .name' -r
