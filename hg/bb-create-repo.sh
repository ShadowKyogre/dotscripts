#!/bin/sh

if [ ! -e "$HOME/.config/.bb_auth" ];then
	2>&1 echo "Can't find bitbucket auth file"
	exit 1
fi

BB_LOGIN="$(sed -n 1p "$HOME/.config/.bb_auth")"
BB_PW="$(sed -n 2p "$HOME/.config/.bb_auth")"
BB_USER="$(sed -n 3p "$HOME/.config/.bb_auth")"

DEF_BB_FILTER=".links.clone[1].href"
BB_FILTER="${BB_FILTER:-${DEF_BB_FILTER}}"

for repo in $@;do
	OWNER="${BB_OWNER:-${BB_USER}}"
	DATA="$(curl --user "${BB_LOGIN}:${BB_PW}" \
		"https://api.bitbucket.org/2.0/repositories/${OWNER}/${repo}" \
		--data name="$repo" \
		--data fork_policy=no_public_forks \
		--data is_private='true' \
		--data scm=hg|jq "${BB_FILTER}" -r)"
	if [ "$DATA" = "null" ];then
		DATA="$(curl -X GET --user "${BB_LOGIN}:${BB_PW}" \
		"https://api.bitbucket.org/2.0/repositories/${OWNER}/${repo}"| \
		jq "${BB_FILTER}" -r)"
	fi
	echo "$DATA"
done
