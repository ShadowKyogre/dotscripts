#!/bin/sh

an="$GIT_AUTHOR_NAME"
am="$GIT_AUTHOR_EMAIL"
cn="$GIT_COMMITTER_NAME"
cm="$GIT_COMMITTER_EMAIL"

if [ "$#" -ge 3 ];then
    if [ "$GIT_COMMITTER_EMAIL" = "$1" ]
    then
        cn="$2"
        cm="$3"
    fi
    if [ "$GIT_AUTHOR_EMAIL" = "$1" ]
    then
        an="$2"
        am="$3"
    fi
fi

echo "export GIT_AUTHOR_NAME=$(printf '%q' "$an")"
echo "export GIT_AUTHOR_EMAIL=$(printf '%q' "$am")"
echo "export GIT_COMMITTER_NAME=$(printf '%q' "$cn")"
echo "export GIT_COMMITTER_EMAIL=$(printf '%q' "$cm")"
