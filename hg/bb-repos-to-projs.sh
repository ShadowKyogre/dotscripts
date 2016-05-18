#!/bin/sh

MAKE_LIST='[.] as $head|reduce inputs as $item ($head; . + [$item])|{repo_ids:.}'

uuids="$(jq -R "$MAKE_LIST")"

BB_LOGIN="$(sed -n 1p "$HOME/.config/.bb_auth")"
BB_PW="$(sed -n 2p "$HOME/.config/.bb_auth")"

if [ "$#" -lt 2 ];then
	exit 1
fi

curl -H "Content-Type: application/json" \
	--user "${BB_LOGIN}:${BB_PW}" \
	"https://api.bitbucket.org/internal/teams/${1}/projects/${2}/repositories/" \
	-X POST \
	-d "${uuids}"
